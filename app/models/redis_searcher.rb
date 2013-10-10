class RedisSearcher

  #Primer paso de la busqueda, envia las palabras y asocia un id a la busqueda
  #Subsiguientemente, envia ese id para recuperar la busqueda y continuarla
  #Cachea datos como phrase_ids
  #Usa un flag para avisar que un SearchVideosJob completo su busqueda
  #Usar un score de match simple
  #Destruir la data con el último video ¿Como le aviso al handler que termino la busqueda?
  #

  attr_accessor :id, :query, :user, :phrase_ids

  def self.find_or_create(user, phrase_ids, query)
    search = REDIS.get search_key(user, phrase_ids.join(",") )

    if search
      Rails.logger.info "Find previous search with id=#{search}"
      Searcher.new(user,phrase_ids,query,search)
    else
      Rails.logger.info "Creating new search for query=#{query}"
      Searcher.new(user,phrase_ids,query)
    end
  end

  def self.find_by_id(id)
    Searcher.new(nil, nil, nil, id)
  end


  def initialize(user, phrase_ids, query, nid=nil)
    @user = user
    @phrase_ids = phrase_ids
    @query = query
    @id = nid || REDIS.incr("search")
    create unless nid
    lock if query
  end

  def create
    REDIS.set search_key, id
    # REDIS.set "search:#{id}:pids", phrase_ids.join(",")
  end

  def search_id_key
    "search:#{id}:key"
  end

  def search_key
    Searcher.search_key(user, phrase_ids.join(","))
  end


  def self.search_key(user, phrase_ids_joined)
    "user:#{user.id}:pids:#{phrase_ids_joined}"
  end

  def locked?
    (REDIS.get Searcher.lock_key(id) ) || false
  end

  def lock
    REDIS.setex(Searcher.lock_key(id), 3000, true)
  end

  def self.lock_key(id)
    "search:#{id}:lock"
  end



  def videos_ids
    unless REDIS.exists videos_ids_key
      finded_videos_ids = []
      phrase_ids.each do |phrase|
        ids =  Phrase.video_ids_for(phrase)
        Resque.enqueue(CrawlPhrasesJob, phrase) if ids.size < 10

        if finded_videos_ids.empty?
          finded_videos_ids << ids

        else
          finded_videos_ids = finded_videos_ids & ids
        end
        finded_videos_ids.flatten!
      end
      REDIS.pipelined do
        finded_videos_ids.each do |id|
          REDIS.sadd videos_ids_key, id
        end
      end
    end
    
        #Provisional 
        new_ids = REDIS.smembers(videos_searched_ids_key)
        Rails.logger.info "new_ids = #{new_ids}"
        new_ids.each do |id|
          vid = Video.find id
          puts "[Model] New video = #{vid.id}: #{vid.title}, #{vid.keywords}"
        end


    if REDIS.scard(videos_searched_ids_key) > 0     
      REDIS.sunionstore videos_ids_key, videos_searched_ids_key, videos_ids_key
    end

    REDIS.smembers videos_ids_key
  end



  def enqueued?
    REDIS.get enqueue_key
  end

  def enqueue_key
    "search:#{id}:enqueue"
  end

  def score_and_sort!
    vids = []
    if REDIS.exists scores_key
      vids = REDIS.smembers videos_searched_ids_key
    else
      vids = videos_ids()
    end

    vids.each do |vid|
      next if user.screen_list.include? vid
      video_phrases_ids = Video.phrase_ids_for(vid)
      #video_score = current_user.score_for_video(vid).to_f
      #logger.info "relevance: 1 / #{video_phrases_ids.size}) "
      video_score = Video.views_score_for(vid) + Video.rating_score_for(vid)

      relevance =  (1 / video_phrases_ids.size).to_f

      #suppression_match = (video_phrases_ids & suppressed_phrase_ids).size
      #logger.debug "Supressed phrases: #{suppressed_phrase_ids.size } and suppression match: #{suppression_match}"

      rarity = 1
      #if suppressed_phrase_ids.size > 0
      #  rarity = 1 + (suppressed_phrase_ids.size  / (1 + suppression_match))
      #end
      total_score = video_score + relevance + rarity
      #puts "total score = #{total_score}"
      REDIS.multi do
        REDIS.srem videos_searched_ids_key, vid
      end
      save_score(vid, total_score)
    end
     puts "length of scored videos= #{REDIS.hlen(scores_key)}"
    
    sort! if vids.size > 0
  end

  def pop_a_top
    continue =true
    popped_video=nil
    while (continue)
      popped_video = REDIS.lpop sorted_key
      continue=false
      continue=true if user.screen_list.include? popped_video
    end
    popped_video
  end

  def save_score(vid,score)
    REDIS.hset scores_key, vid, score
  end

  def scores_key
    "search:#{id}:scores"
  end

  def sort!
    sorted = (REDIS.hgetall scores_key).sort {|a,b| a[1] <=> b[1]}
    REDIS.pipelined do
      sorted.each do |video_hash|
        #puts "LPOP in Sort List -> #{video_hash[0]}"
        REDIS.rpush sorted_key, video_hash[0]
      end
    end
  end

  def sorted_key
    "search:#{id}:sorted"
  end


  def find_a_video(extra_enqueue=false)
      
    unless enqueued?
      Resque.enqueue(SearchVideosJob, query, id)
      #SearchVideosJob.perform query, id
      REDIS.setex enqueue_key, 60, true
    end

    FastSearchVideosJob.perform(query, id) if extra_enqueue


    new_videos = REDIS.smembers videos_searched_ids_key
    Rails.logger.info "[Model] #{new_videos.size} videos returned from YT at the moment with #{query}"

    score_and_sort!

    video_id = pop_a_top
    vid=nil
    if video_id
      vid = Video.find video_id
      vid.score         = user.score_for_video  video_id
      vid.phrases_score = user.get_avg_phrase_score_for video_id
      vid.from          = 'search'
      vid.p_neutral     = user.avg_p_like
    else
      destroy
    end

    vid || false
  end

  def destroy
    REDIS.pipelined do
      REDIS.del enqueue_key
      REDIS.del videos_ids_key
      REDIS.del videos_searched_ids_key
      REDIS.del search_key if phrase_ids
      REDIS.del scores_key
      REDIS.del sorted_key
      REDIS.del Searcher.lock_key(id)
    end
  end


  def self.destroy(id)
    search = Searcher.find_by_id id

    return false if search.locked?

    search.destroy
    return true

  end

  def videos_ids_key
    "search:#{id}:vids"
  end

  def videos_searched_ids_key
    "search:#{id}:svids"
  end



end

