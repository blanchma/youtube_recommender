# Input a subject (user or channel) in the constructor, 
# ask for a recommendation (pop_a_recommendation) 
# and returns a video
class SphinxRecommender
  attr_accessor :subject, :debug
  attr_accessor :phrase_scores_used, :loser_phrase_ids, :winner_id
  attr_accessor :videos, :sorted_videos, :query_for_video, :videos_for_phrase


  def logger
    @logger ||= Rails.logger
  end

  def initialize(subject)
    logger.debug "Sphinx Recommender init"
    self.subject  = subject
    self.debug = subject.debug if subject.methods.include? :debug
    # the phrase scores we actually used when searching
    self.phrase_scores_used = []
    # any phrase_ids that returned zero results (so we should search YT for them)
    self.loser_phrase_ids   = []
    self.videos={}
    self.query_for_video={}
    self.videos_for_phrase={}

  end

  def pop_a_recommendation
    logger.info "Sphinx Recommender running"
    timer "Query a video for #{subject.id}-#{subject.class.name}" do
      @video = query_a_video
    end

    if @video && subject.is_a?(User)
        timer 'Suppressing phrases to increase diversity...' do          
          subject.suppress_words_in!([@video])                 
          if @query_for_video && @query_for_video[@video.id.to_s]
              @query_for_video[@video.id.to_s].each do |phrase_id|
                  PhraseScore.suppress(subject, phrase_id)  
            end
          end
        end
    else
      logger.info "It's a channel so don't suppress any phrase"
    end
    
    #The winner
    
    @video
  end


  def query_a_video
    #First step, recover up to 75 phrases ordered by the best scored
    phrase_scores_for_search()

    logger.warn "#{subject.id}-#{subject.class.name} have phrases_score #{@phrase_for_search.size}" if @phrase_for_search.size < 10

    #Second, gather n videos using the top phrases
    while @videos.size < 400
      phrase_score = @phrase_for_search.shift
      break unless phrase_score

      #Search videos with the top phrase
      num_hits = query_videos_from_phrase(phrase_score)
      
      @phrase_scores_used << phrase_score

      if num_hits < 2
        @loser_phrase_ids << phrase_score.phrase_id
      end

      logger.warn "Num hits for #{phrase_score.text} is #{num_hits}"
    end

    #Top phrases with no videos in db, search in YT 
    enqueue_search_for_loser_phrases()

    #Third, sort videos     
    begin
      timer "Sorting videos: " do
        @sorted_videos = @videos.sort do |a,b|
          #   puts "b => #{b[1]} / a => #{a[1]}"
          b[1] <=> a[1]
        end
      end
    rescue Exception => e
      logger.error "@videos = #{@videos}"
      raise e
    end

  
    #Finally, catch the top scored
    if @sorted_videos.first
      @winner_id = @sorted_videos.first[0]
      #Only for debug
      load_top_hit_with_debug()
    else
      return nil
    end
  end

  def load_top_hit_with_debug
    vid = nil
    
      result_id =  @winner_id
      logger.info "TopHit id: #{result_id}"

        
      vid = Video.find_by_id(result_id)
      if vid
        
        vid.score         = subject.score_for_video result_id
        vid.from          = 'mynewtv'
        vid.query         = @query_for_video[result_id]
        if debug
            timer "Debugging info for top hit..." do  
          vid.phrases_score = subject.get_avg_phrase_score_for  result_id
          vid.views_score   = "#{Video.views_score_for(result_id) * VIEWS_SCORE_COEFFICIENT} ( #{Video.views_score_for(result_id)} * #{VIEWS_SCORE_COEFFICIENT})"
          vid.rating_score  = "#{Video.rating_score_for(result_id) * RATING_SCORE_COEFFICIENT } ( #{Video.rating_score_for(result_id)} * #{RATING_SCORE_COEFFICIENT})"
          vid.category_score = "#{subject.get_category_score(result_id) * CATEGORY_SCORE_COEFFICIENT} ( #{subject.get_category_score(result_id)} * #{CATEGORY_SCORE_COEFFICIENT})"
          vid.p_neutral     = subject.avg_p_like
          vid.words_debug = debug_phrases_in_video(vid).join('<br/>')
          vid.queryWords = []
          vid.query.each do |phrase_id|
            phrase_text = Phrase.select("text").find phrase_id
            vid.queryWords << phrase_text
          end
      end
        end
        

        if debug
          debug_rows = []
          timer "Debug info for top 10 videos..." do
            # get top 5 hits to debug info
            @sorted_videos.first(10).each do |video_id, score|
              next if video_id == result_id
              video= Video.select("id, title, youtube_id, categories").includes(:phrases).find(video_id)
              debug_rows << {
                :title         => video.title,
                :youtube       => "http://youtube.com/v/#{video.youtube_id}",
                :score         =>  score,#sprintf( '%.5f',subject.score_for_video(video_id) ),
                :phrases_score => sprintf( '%.4f', subject.get_avg_phrase_score_for( video_id) ),
                :phrases_score_c => sprintf( '%.4f', subject.get_avg_phrase_score_for( video_id) * PHRASES_SCORE_COEFFICIENT),
                :views_score   => sprintf( '%.4f', Video.views_score_for(video_id)),
                :views_score_c   => sprintf( '%.4f', Video.views_score_for(video_id) * VIEWS_SCORE_COEFFICIENT),
                :rating_score  => sprintf( '%.4f', Video.rating_score_for(video_id)),
                :rating_score_c  => sprintf( '%.4f', Video.rating_score_for(video_id) * RATING_SCORE_COEFFICIENT),
                :category => video.categories,
                :category_score => sprintf( '%.4f', subject.get_category_score(video_id)),
                :category_score_c => sprintf( '%.4f', subject.get_category_score(video_id) * CATEGORY_SCORE_COEFFICIENT),
                :id            => video_id,
                :tags          => debug_phrases_in_video(video).join('<br/>')

              }
            end
          end#timer
          vid.debug_result_rows = debug_rows
          
          #see what the hell they tried to do here
          vid.phrase_scores_searched = phrase_scores_searched_debug
        end
      end
   
    vid
  end

  def enqueue_search_for_loser_phrases
    phrases = Phrase.find(self.loser_phrase_ids)
    logger.warn "Scheduling crawl for loser phrases: #{phrases.collect(&:text).join(',')}"
    self.loser_phrase_ids.each {|phrase_id| Resque.enqueue(CrawlPhrasesJob, phrase_id)}
  end

  def debug_phrases_in_video(video)
    phrase_ids = video.phrases.select("id").map {|v| v.id}

    debug_phrases = phrase_ids.collect do |phrase_id|
      ps = subject.phrase_scores.where(:phrase_id=>phrase_id).first
      if ps
        score = sprintf('%.5f', ps.score)
        unseen = sprintf('%.4f', ps.p_unseen)
        rare = sprintf('%.4f', ps.p_rare)
        weight= sprintf('%.4f', ps.p_weighted)

        "<span class='word'>#{ps.text}</span> (#{score}=#{weight} * #{rare} * #{unseen})"
      else
        phrase = Phrase.select("text").find(phrase_id)
        "<span class='word'>#{phrase.text}</span> neutral"
      end
    end

    debug_phrases
  end

  def set_score_for(video_id)
    # only set the score if one is returned. nil is returned if we already have the
    # score for this vid
    unless @videos[video_id]
      score = 0
      score = subject.score_for_video video_id
      
      logger.info "Score for video_id: #{video_id} is #{score}"
      @videos[video_id] = score if score
    end
  end

  def phrase_scores_for_search

    unless @phrase_for_search.nil? || @phrase_for_search.empty?
      return @phrase_for_search
  else
      logger.warn "LOADING PHRASE SCORES FOR SEARCH FOR #{subject.id} - #{subject.class.name}"
      timer "Query for PhraseScores" do
        @phrase_for_search = subject.phrase_scores.for_search.limit(50).sort_by(&:score).reverse
      end
    end
    logger.info "#{subject.id}-#{subject.class.name} has #{phrase_scores_for_search.size}"
    @phrase_for_search
  end

  def query_videos_from_phrase(phrase_score)
    phrase_id = phrase_score.phrase_id
    count_words = phrase_score.text.split.size
    video_hit_ids = []
    timer "Searching with Sphinx for #{phrase_score.text}(#{phrase_id})" do
      if count_words > 1
        video_hit_ids = Video.search_for_ids phrase_score.text
      else
        video_hit_ids = Video.search_for_ids phrase_score.text, :rank_mode => :bm25
      end
    end
    
    video_hit_ids = video_hit_ids.collect{|i| i.to_s}
    video_hit_ids =  video_hit_ids - subject.watched_ids - subject.liked_ids - subject.hated_ids - subject.playlist.ids 
    

    #Scoring all the video hits and saving scores to redis
    timer "Scoring #{video_hit_ids.size} video hits for phrase id: '#{phrase_id}'" do
      #score_ids(video_hit_ids)
      video_hit_ids.each do |video_id|
        set_score_for(video_id)
        
        if debug
          @videos_for_phrase[phrase_id]=[] unless @videos_for_phrase[phrase_id]
          @videos_for_phrase[phrase_id] << video_id
          @query_for_video[video_id]=[] unless @query_for_video[video_id]
          @query_for_video[video_id] << phrase_id
        end
      end
    end
    logger.info "Hits for #{phrase_id} = #{video_hit_ids.size}"
    video_hit_ids.size
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
        :label => "<span class='word'><b>#{ps.text}</b></span> (#{score}=#{weight} * #{rare} * #{unseen})",
        :top_hits   => top_hits_for_phrase_id(ps.phrase_id)
      }
      list << this_score
    end
    list
  end

  def top_hits_for_phrase_id(phrase_id, limit=3)
    results = []
    scored_videos = {}

    videos = @videos_for_phrase[phrase_id]

    return [] unless videos

    videos.each { |vid| scored_videos[vid]= @videos[vid] }

    sorted_videos = scored_videos.sort do |a,b|
      #   puts "b => #{b[1]} / a => #{a[1]}"
      b[1] <=> a[1]
    end

    sorted_videos - [@winner_id]
    
    sorted_videos.first(5).each do |item|
      video_id = item[0]
      v = Video.find(video_id)
      score = sprintf('%.5f', subject.score_for_video(video_id) )
      results << {
        :id       => video_id,
        :score    => score,
        :category => v.categories,
        :title    => v.title,
        :keywords => debug_phrases_in_video(v)
      }
    end
    results
  end


end

