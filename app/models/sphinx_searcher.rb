class SphinxSearcher

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
      SphinxSearcher.new(user,phrase_ids,query,search)
    else
      Rails.logger.info "Creating new search for query=#{query}"
      SphinxSearcher.new(user,phrase_ids,query)
    end
  end

  def self.find_by_id(id)
    SphinxSearcher.new(nil, nil, nil, id)
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
    SphinxSearcher.search_key(user, phrase_ids.join(","))
  end


  def self.search_key(user, phrase_ids_joined)
    "user:#{user.id}:pids:#{phrase_ids_joined}"
  end

  def locked?
    (REDIS.get SphinxSearcher.lock_key(id) ) || false
  end

  def lock
    REDIS.setex(SphinxSearcher.lock_key(id), 3000, true)
  end

  def self.lock_key(id)
    "search:#{id}:lock"
  end


  def enqueued?
    REDIS.get enqueue_key
  end

  def enqueue_key
    "search:#{id}:enqueue"
  end



  def find_a_video(extra_enqueue=false)

    unless enqueued?
      Resque.enqueue(FastSearchVideosJob, query, id )
      REDIS.setex enqueue_key, 60, true
    end

    videos_found_ids = Video.search_for_ids query
    
    videos_found_ids = videos_found_ids.collect{|i| i.to_s}

    videos_found_ids = videos_found_ids - user.screen_list
=begin
    videos_found_ids.first(500).each do |video_id|
      scored_videos[video_id] = user.score_for_video video_id
    end

    scored_videos.sort {|a,b| b[1] <=> a[1]}
=end

    video_id = videos_found_ids.first if videos_found_ids

    if video_id
      vid = Video.find(video_id)
      vid.score         = user.score_for_video  video_id
      vid.phrases_score = user.get_avg_phrase_score_for video_id
      vid.from          = 'search'
      vid.p_neutral     = user.avg_p_like
    else
      destroy
    end

    vid || nil
  end

  def destroy
    REDIS.pipelined do
      REDIS.del enqueue_key
      REDIS.del search_key if phrase_ids
      REDIS.del SphinxSearcher.lock_key(id)
    end
  end


  def self.destroy(id)
    search = SphinxSearcher.find_by_id id

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

