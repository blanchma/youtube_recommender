module Recommendable
  attr_accessor :playlist  

  def playlist
    @playlist ||= Playlist.new(self)
  end
  
  def like_video!(video)
    video.phrases.each do |phrase|
      ps = phrase_scores.find_or_create_by_phrase_id(phrase.id)
      ps.likes = ps.likes + 1
      ps.save
      Resque.enqueue(CrawlLikedPhraseJob, phrase.id)
    end
  end

  def hate_video!(video)
    video.phrases.each do |phrase|
      ps = phrase_scores.find_or_create_by_phrase_id(phrase.id)
      ps.hates += 1
      ps.save
    end
  end
  
  def watch_video!(video)
     REDIS.sadd watched_key, video.id
  end
  
 
  def total_votes
    @total_votes ||= phrase_scores.sum(:total)
  end

  def avg_p_like
    return @avg_p_like if @avg_p_like

    @avg_p_like = redis_avg_p_like
    return @avg_p_like.to_f unless @avg_p_like.nil?

    total = phrase_scores.voted.count

    if total > 0
      if ratings.voted.count > 75
        @avg_p_like = phrase_scores.voted.sum(:p_like) / total
      else
        @avg_p_like = 0.494682091928226
      end
    else
      @avg_p_like = 0.0
    end

    redis_avg_p_like=@avg_p_like
    @avg_p_like
  end

  def redis_avg_p_like=(value)
    REDIS.setex "#{self.class.name.downcase}-#{id}:avg",120, value
  end

  def redis_avg_p_like
    REDIS.get "#{self.class.name.downcase}-#{id}:avg"
  end

  def recently_watched(limit=200)
    ratings.watched.newest.limit(limit).collect(&:video_id).uniq

  end

  def score_for_video(video_id)
    mynewtv_score = get_video_score_cache(video_id)
    unless mynewtv_score
      begin
        phrase_score = get_avg_phrase_score_for(video_id) * PHRASES_SCORE_COEFFICIENT
        views_score = Video.views_score_for(video_id) * VIEWS_SCORE_COEFFICIENT
        rating_score = Video.rating_score_for(video_id) * RATING_SCORE_COEFFICIENT
        category_score = get_category_score(video_id) * CATEGORY_SCORE_COEFFICIENT
        total_weight = PHRASES_SCORE_COEFFICIENT + VIEWS_SCORE_COEFFICIENT + RATING_SCORE_COEFFICIENT + CATEGORY_SCORE_COEFFICIENT
        total_score = phrase_score + views_score + rating_score + category_score 
        mynewtv_score = total_score / total_weight.to_f
        
        set_video_score_cache(video_id, mynewtv_score)
      rescue Exception => ex        
            Rails.logger.error ex            
            return "0"
      end
    end
    Rails.logger.debug "video_id score=#{mynewtv_score.to_s}"
    mynewtv_score.to_s
  end


  def suppress_words_in!(videos)
    videos.each do |video|
      suppress_phrases!(video.phrases)
    end
  end

  def suppress_phrases!(phrases)
      
    return false if phrases.empty?

    missing = phrases.reject {|phrase| phrase_scores.exists?(:phrase_id => phrase.id)}
    unless missing.empty?
      Rails.logger.debug "Adding neutral phrase_scores for: #{missing.collect(&:text).inspect}"
      missing.each do |phrase|
        phrase_score = phrase_scores.create(:phrase_id => phrase.id)
        phrase_score.suppress!
      end
    end

    phrases.each do |phrase|
      #Rails.logger.info "Suprressing #{phrase.text}"
      PhraseScore.suppress(self, phrase.id)
    end
  end

  def watched_ids
    REDIS.smembers watched_key
  end

  def watched_key
    "videos:#{self.class.name.downcase}-#{self.id}:watched"
  end

  def hated_ids
    REDIS.smembers hated_key
  end

  def hated_key
    "videos:#{self.class.name.downcase}-#{self.id}:hated"
  end

  def liked_ids
    REDIS.smembers(liked_key)
  end

  def liked_key
    "videos:#{self.class.name.downcase}-#{self.id}:liked"
  end

   def enqueued_ids
    playlist.ids
  end

  def screen_list_key
    "videos:#{self.class.name.downcase}-#{self.id}:screen"
  end

  def screen_list
    REDIS.smembers(screen_list_key).map {|v| v.to_i}
  end

  def screen_list_as_strs
    REDIS.smembers(screen_list_key)
  end

  def add_to_screen_list(id)
    REDIS.sadd screen_list_key, id
  end

  def clear_screen_list
    REDIS.del screen_list_key
  end

  def screen_list=(ids)
    REDIS.del screen_list_key
    ids.each do |id|
      REDIS.sadd screen_list_key, id.strip
    end
    REDIS.expire screen_list_key, 1800
  end

  def get_category_score(video_id)
    cat_id = Video.category_id_for(video_id)
    category_score = CategoryScore.score_for(self, cat_id)
    category_score.to_f
  end


  def get_avg_phrase_score_for (video_id)
    avg_phrase_score = 0.3
    phrase_ids = []

    score = get_avg_phrase_score_cache(video_id)
    return score if score


    timer "Select Phrases from Video #{video_id}" do
      #phrase_ids = REDIS.smembers "video:#{video_id}:phrases"
      phrase_ids = Video.select("id").includes(:phrases).find(video_id).phrases.select("id").map { |phrase| phrase.id }
    end

    scores = []
    timer "    geting scoring video #{video_id}" do
      phrase_ids.each do |phrase_id|      
        phrase_score = PhraseScore.score_for self, phrase_id

        next if phrase_score.nil?
        timer "          scoring phrase(#{phrase_id}): #{phrase_score}" do
          Rails.logger.debug "PhraseScore(#{phrase_id}): #{phrase_score.to_f}"
          scores << phrase_score.to_f
        end
      end #phrase_ids_collect
    end

    avg_phrase_score = scores.sum/scores.size if scores.size > 0
    set_avg_phrase_score_cache(video_id, avg_phrase_score)
    
    avg_phrase_score
  end

  private

  def set_avg_phrase_score_cache(video_id, score)
    REDIS.setex "#{self.class.name.downcase}-#{self.id}:avg_phrase_score:video:#{video_id}", 360, score
  end

  def get_avg_phrase_score_cache(video_id)
    REDIS.get "#{self.class.name.downcase}-#{self.id}:avg_phrase_score:video:#{video_id}"
  end


  def get_video_score_cache(video_id)
    REDIS.get "#{self.class.name.downcase}-#{self.id}:score_for_video:#{video_id}"
  end

  def set_video_score_cache(video_id, mynewtv_score)
    REDIS.set "#{self.class.name.downcase}-#{self.id}:score_for_video:#{video_id}", mynewtv_score
    REDIS.expire "#{self.class.name.downcase}-#{self.id}:score_for_video:#{video_id}", 360
  end

  
end
