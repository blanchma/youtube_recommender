class Array
  def from_zset_with_scores
    members, scores = partition.with_index{|x,i| (i&1).zero?}
    members.zip(scores)
  end
end

class RedisRecommender
  attr_accessor :query_id
  attr_accessor :user
  attr_accessor :debug
  attr_accessor :phrase_scores_used
  attr_accessor :loser_phrase_ids


  def logger
    @logger ||= Rails.logger
  end

  def initialize(user, debug=true)
    logger.info "Redis Recommender init"
    self.user  = user
    self.debug = debug
    self.query_id = REDIS.incr 'queries'
    # the phrase scores we actually used when searching
    self.phrase_scores_used = []
    # any phrase_ids that returned zero results (so we should search YT for them)
    self.loser_phrase_ids   = []
    #self.user.update_phrase_cache_if_expired!
  end

  def pop_a_recommendation
    logger.info "Redis Recommender running"
    timer "Query a video for #{user.email}" do
      @video = query_a_video
    end

    timer 'Suppressing...' do
      user.suppress_words_in!([@video])
    end

    @video
  end


  def query_a_video
    #First step, recover up to 75 phrases ordered by the best scored
    phrase_scores = phrase_scores_for_search
    logger.warn "#{user.email} have phrases_score #{phrase_scores.size}" if phrase_scores.size < 10

    while hits_scored < 700
      phrase_score = phrase_scores.shift
      break unless phrase_score

      num_hits = query_for_phrase(phrase_score.phrase_id)

      self.phrase_scores_used << phrase_score

      if num_hits < 2
        self.loser_phrase_ids << phrase_score.phrase_id
      end

      logger.warn "Num hits for #{phrase_score.text} is #{num_hits}"
    end

    enqueue_search_for_loser_phrases()

    top_hits = nil
    timer "Sorting our #{hits_scored} hits..." do
      top_hits = REDIS.sort "query:#{query_id}:videos", :by => "query:#{query_id}:scores:*", :order => 'DESC', :limit => [0,5]
    end

    logger.debug "top hits: #{top_hits.inspect}"

    load_top_hit_with_debug(top_hits)
  end

  def load_top_hit_with_debug(top_ids)
    vid = nil
    timer "Debugging info for top hit..." do
      result_id = top_ids.first
      logger.info "TopHit id: #{result_id}"


      vid = Video.find_by_id(result_id)
      if vid
        vid.score         = user.score_for_video result_id
        vid.from          = 'mynewtv'
        if debug
          vid.phrases_score = user.get_avg_phrase_score_for  result_id
          vid.views_score   = "#{Video.views_score_for(result_id) * VIEWS_SCORE_COEFFICIENT} ( #{Video.views_score_for(result_id)} * #{VIEWS_SCORE_COEFFICIENT})"
          vid.rating_score  = "#{Video.rating_score_for(result_id) * RATING_SCORE_COEFFICIENT } ( #{Video.rating_score_for(result_id)} * #{RATING_SCORE_COEFFICIENT})"
          vid.category_score = "#{user.get_category_score(result_id) * CATEGORY_SCORE_COEFFICIENT} ( #{user.get_category_score(result_id)} * #{CATEGORY_SCORE_COEFFICIENT})"
          vid.p_neutral     = user.avg_p_like
          vid.words_debug = debug_phrases_in_video(result_id).join('<br/>')
        end


        if debug
          debug_rows = []
          timer "Debug info for top 10 videos..." do
            # get top 5 hits to debug info
            top_ids.first(10).each do |video_id|
              next if video_id == result_id
              video= Video.select("title, youtube_id, categories").find(video_id)
              debug_rows << {
                :title         => video.title,
                :youtube       => "http://youtube.com/v/#{video.youtube_id}",
                :score         =>  sprintf( '%.5f',user.score_for_video(video_id) ),
                :phrases_score => sprintf( '%.4f', user.get_avg_phrase_score_for( video_id) ),
                :phrases_score_c => sprintf( '%.4f', user.get_avg_phrase_score_for( video_id) * PHRASES_SCORE_COEFFICIENT),
                :views_score   => sprintf( '%.4f', Video.views_score_for(video_id)),
                :views_score_c   => sprintf( '%.4f', Video.views_score_for(video_id) * VIEWS_SCORE_COEFFICIENT),
                :rating_score  => sprintf( '%.4f', Video.rating_score_for(video_id)),
                :rating_score_c  => sprintf( '%.4f', Video.rating_score_for(video_id) * RATING_SCORE_COEFFICIENT),
                :category => video.categories,
                :category_score => sprintf( '%.4f', user.get_category_score(video_id)),
                :category_score_c => sprintf( '%.4f', user.get_category_score(video_id) * CATEGORY_SCORE_COEFFICIENT),
                :id            => video_id,
              :tags          => debug_phrases_in_video(video_id).join('<br/>') }
            end
          end
          vid.debug_result_rows = debug_rows
          #see what the hell they tried to do here
          vid.phrase_scores_searched = phrase_scores_searched_debug
        end

      else
        REDIS.srem "phrase:#{phrase_id}:videos", result_id
        query_a_video
      end


    end


    vid
  end

  def enqueue_search_for_loser_phrases
    phrases = Phrase.find(self.loser_phrase_ids)
    logger.warn "Scheduling crawl for loser phrases: #{phrases.collect(&:text).join(',')}"
    self.loser_phrase_ids.each {|phrase_id| Resque.enqueue(CrawlPhrasesJob, phrase_id)}
  end

  def debug_phrases_in_video(video_id)
    # REDIS.zunionstore key, ["user:#{user.id}:phrase_scorse", video_phrases_key]
    # phrase_id_with_score = REDIS.zrevrange(key, 0, -1, :with_scores => true).from_zset_with_scores
    phrase_ids = REDIS.smembers "video:#{video_id}:phrases"

    phrase_ids.collect do |phrase_id|
      if ps = user.phrase_scores.where(:phrase_id=>phrase_id).first
        # redis_score = REDIS.hget "users:#{user.id}:phrase_scores", ps.phrase_id

        # "<span class='word'>#{ps.text}</span>^#{ps.p_weighted} (#{ps.p_tanh} * #{ps.p_unseen}) [r: #{redis_score}]"
        score = sprintf('%.5f', ps.score)
        unseen = sprintf('%.4f', ps.p_unseen)
        rare = sprintf('%.4f', ps.p_rare)
        weight= sprintf('%.4f', ps.p_weighted)

        "<span class='word'>#{ps.text}</span> (#{score}=#{weight} * #{rare} * #{unseen})"
      else
        phrase = Phrase.find(phrase_id)
        "<span class='word'>#{phrase.text}</span> neutral"
      end
    end
  end

  def hits_scored
    REDIS.get("query:#{query_id}:hits_scored").to_i
  end



  def score_ids(video_ids)
    video_ids.each do |video_id|
      set_score_for(video_id)
    end
  end

  def score_for(video_id)
    REDIS.get("query:#{query_id}:scores:#{video_id}").to_f
  end

  def set_score_for(video_id)
    # only set the score if one is returned. nil is returned if we already have the
    # score for this vid
    unless REDIS.exists "query:#{query_id}:scores:#{video_id}"
      score = 0
      timer "score of #{video_id}" do
        score = user.score_for_video video_id
      end
      REDIS.pipelined do
        REDIS.set  "query:#{query_id}:scores:#{video_id}", score
        REDIS.incr "query:#{query_id}:hits_scored"
      end
    end
  end

  def phrase_scores_for_search

    unless @phrase_scores_for_search.nil? || @phrase_scores_for_search.empty?
      return @phrase_scores_for_search
    else
      logger.warn "LOADING PHRASE SCORES FOR SEARCH FOR #{user.email}"
      timer "Query for PhraseScores" do
        @phrase_scores_for_search = user.phrase_scores.for_search.limit(75).sort_by(&:score).reverse
      end
    end
    logger.info "#{user.email} has #{phrase_scores_for_search.size}"
    @phrase_scores_for_search
  end

  def query_for_phrase(phrase_id)
    # remove previously watched videos
    # timer "Rebuild index for #{phrase_id}" do
    #   logger.info "How much videos about #{phrase_id}? #{Phrase.count_from_redis phrase_id }"
    #Phrase.rebuild_index(phrase_id) if (REDIS.scard "phrase:#{phrase_id}:videos") == 0
    # end

    timer "Remove watched videos from queried videos" do
      REDIS.sdiffstore "query:#{query_id}:videos_for:#{phrase_id}", "phrase:#{phrase_id}:videos", user.watched_key, user.skipped_key, user.hated_key, user.playlist.ids_key
    end

    hits = REDIS.scard "query:#{query_id}:videos_for:#{phrase_id}"
    # logger.debug "We have #{hits} potential hits"


    video_hit_ids = []

    if hits > 500
      # sort by views score (since we have that, anyway), take the top 500
      # timer "Sorting potential hits by views_score..." do
      video_hit_ids = 0
      timer "Sorting video_hits_ids for phrase id: '#{phrase_id}'" do
        video_hit_ids = REDIS.sort "query:#{query_id}:videos_for:#{phrase_id}", :by => "video:*:views_score", :limit => [0,500], :order => 'DESC'
      end
    else
      video_hit_ids = REDIS.smembers "query:#{query_id}:videos_for:#{phrase_id}"
    end


    #Scoring all the video hits and saving scores to redis
    timer "Scoring all video hits for phrase id: '#{phrase_id}'" do
      score_ids(video_hit_ids)
    end

    #Paranoic mode! Just to be sure that any removed or false reference will broke the algorithm
    video_hit_ids.reject! {|video_id| !Video.exists?(video_id) }

    #Put in Redis all the videos for this particular phrase
    REDIS.pipelined do
      video_hit_ids.each {|video_id| REDIS.sadd "query:#{query_id}:videos", video_id}
    end

    video_hit_ids.size
  end




  def destroy
    keys = REDIS.keys("query:#{query_id}:*")
    REDIS.pipelined do
      keys.each do |key|
        REDIS.del key # hose in 1 min
      end
    end
  end


  def phrase_scores_searched_debug
    phrase_scores = nil
    if self.phrase_scores_used.empty?
      logger.warn "***** I AM USING CRAPPY DEBUG INFO!"
      phrase_scores = self.phrase_scores_for_search
    else
      phrase_scores = self.phrase_scores_used
    end

    list = []

    phrase_scores.each do |ps|
      score = sprintf('%.5f', ps.score)
      unseen = sprintf('%.4f', ps.p_unseen)
      rare = sprintf('%.4f', ps.p_rare)
      weight= sprintf('%.4f', ps.p_weighted)
      this_score = {
        :phrase_id  => ps.phrase_id,
        :text       => ps.text,
        :p_weighted => "<span class='word'><b>#{ps.text}</b></span> (#{score}=#{weight} * #{rare} * #{unseen})",
        :top_hits   => top_hits_for_phrase_id(ps.phrase_id)
      }
      list << this_score
    end
    list
  end

  def top_hits_for_phrase_id(phrase_id, limit=3)
    video_ids = REDIS.sort "query:#{query_id}:videos_for:#{phrase_id}", :by => "query:#{query_id}:scores:*", :order => "DESC", :limit => [0,limit]
    results = []
    video_ids.each do |video_id|
      v = Video.find(video_id)
      score = user.score_for_video video_id
      results << {
        :id       => video_id,
        :score    => score,
        :category => v.categories,
        :title    => v.title,
        :keywords => debug_phrases_in_video(video_id)
      }
    end
    results
  end


end

