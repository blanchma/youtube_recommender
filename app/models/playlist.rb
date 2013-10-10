# Data structure to save and retrieve videos in a queue
# using Redis as no-sql database
# TODO: decouple function next and prev from a
# specific source like Rating or SphinxRecommender

class Playlist
  attr_accessor :index, :last_index, :subject

  LIMIT_JSONS = 50
  LIMIT_IDS = 250

  def initialize(subject)
    @subject = subject
  end

  def peek(limit=1, id=nil)
    length = REDIS.llen(queue_key).to_i
    videos = []

    if id
      init_index = video_index(id)
    end

    unless init_index
      if subject.is_a? Channel
        init_index = size > 5 ? size - 5 : 0
      else
        init_index = self.index > 0 ? self.index : (size > 5 ? size - 5 : 0)
      end
    end
    
    video_ids = REDIS.lrange queue_key, init_index, (init_index + limit)

    if video_ids.nil? || video_ids.empty?
      videos << self.next(id)
    else
      video_ids.each do |id|
        videos << self.get(id)
      end 
    end
      
      "[#{videos.join(',')}]"
  end

  def queue
    REDIS.lrange queue_key, 0,100
  end


  def next(id=nil)

    video = nil
    Rails.logger.info "next/#{id}"
    next_id = find_next(id)

    if next_id
      video = get(next_id)
    else
      Rails.logger.debug "Next require Sphinx Recommender"
      recommender = SphinxRecommender.new(subject)
      video = recommender.pop_a_recommendation
      
      if video
        Rails.logger.debug "Sphinx Recommender return #{video.id} - #{video.title}"
        #video.rating_from subject        
        append(video)
        @id = video.id
        video = video.to_json
      end      
    end
    
    if video && video_index(id) && video_index(id) - ids.size < 4
      Rails.logger.info "Sending to cache more recommendations for the playlist"
      Resque.enqueue(CachePlaylistJob, subject.id)
    end

    Rails.logger.info "Next video is #{@id}"
    video
  end 

  def previous(id)

    video = nil
    Rails.logger.info "previous/#{id}"
    prev_id = find_previous(id)
    
    if prev_id
      video = get(prev_id)
    else
      if subject.is_a? User
        Rails.logger.debug "Previous require Sphinx Recommender"
        last = subject.ratings.select("id").where({:video_id => id}).last

        #the video was rated
        if last
          rating = subject.ratings(:include =>[:video]).select("id, video_id, action").where("video_id != ?", id).before(last.id).first

          #the video was not rated, so, get the last rated video
        else
          rating = subject.ratings.newest.first
        end

        if rating && rating.video
          video = rating.video        
          Rails.logger.debug "Video rated before: #{video.id} - #{video.title}" if video
          #video.rating_from subject if video
          prepend(video)
          @id = video.id
          video = video.to_json
          Rails.logger.info "Prev video is #{@id}"
        end
      end
    end
    
    video
  end

  def reset_index
    REDIS.set index_key, 0
  end

  def index
    position = 0
    if REDIS.exists index_key
      position = REDIS.get index_key
    end
    REDIS.set index_key, position
    position.to_i
  end

  def index=(position)
    REDIS.set index_key, position
  end


  def update_index(video_id)
    last_index =video_index(video_id)
    self.index= last_index + 1 if last_index
  end

  def video_index(video_id)
    queue.index(video_id.to_s)
  end

  def ids
    REDIS.smembers ids_key || []        
  end

  def prepend(video)
    unless video.nil? || ids.include?(video.id.to_s)
      json = video.to_json
      REDIS.sadd  ids_key,     video.id
      REDIS.hset  jsons_key,  video.id, json
      REDIS.lpush queue_key,     video.id
      self.index= self.index + 1
      shorten_ids if size > LIMIT_IDS        
      shorten_jsons if size_jsons > LIMIT_JSONS
    end
  end

  def append(video)
    unless video.nil? || ids.include?(video.id.to_s)
      json = video.to_json
      REDIS.sadd  ids_key,     video.id
      REDIS.hset  jsons_key,  video.id, json
      REDIS.rpush queue_key,     video.id   
      
      shorten_ids if size > LIMIT_IDS        
      shorten_jsons if size_jsons > LIMIT_JSONS        
    end
  end
  
  def replace_video(video)
    video_index = video_index(video.id)
    if video_index && video_index >= 0
      json = video.to_json
      REDIS.sadd  ids_key,     video.id
      REDIS.hset  jsons_key,  video.id, json
    end
    
  end


  def remove(video_or_id)
    video_id = video_or_id.kind_of?(Video) ? video_or_id.id : video_or_id

    if REDIS.sismember ids_key, video_id

      if video_index(video_id) < self.index
        self.index= self.index + 1
      end

      Rails.logger.warn "REMOVING VIDEO: #{video_id} FROM REDIS PLAYLIST!"
      # delete from set of playlist Playlist.ids
      REDIS.srem  ids_key,   video_id
      # delete the id from the ordered playlist Playlist.ids
      REDIS.lrem queue_key, 0, video_id
      # delete the json in the id => json hash
      REDIS.hdel jsons_key, video_id
      return true
    end
    false
  end

  def get(video_id)
    video = REDIS.hget jsons_key, video_id  
    if video.nil? || video == "null"
      json = Video.find_by_id(video_id).to_json
      REDIS.hset  jsons_key,  video_id, json
      video = json
    end
    
    video
  end

  def size
    REDIS.llen queue_key
  end

  def size_jsons
    REDIS.hlen jsons_key
  end

  def sanitize
    list_of_ids = self.queue
    list_of_ids.uniq!
    list_of_ids.each do |id|
      REDIS.rpush queue_key, id
    end
  end


  def clear
    REDIS.del ids_key
    REDIS.del jsons_key
    REDIS.del queue_key
    REDIS.del index_key
    true
  end

  def index_key
    "playlist:#{subject.class.to_s.downcase}:#{subject.id}:index"
  end


  def queue_key
    "playlist:#{subject.class.to_s.downcase}:#{subject.id}:queue"
  end

  def ids_key
    "playlist:#{subject.class.to_s.downcase}:#{subject.id}:ids"
  end

  def jsons_key
    "playlist:#{subject.class.to_s.downcase}:#{subject.id}:jsons"
  end

  def self.remove_video_from_all(video_id)
      Rails.logger.info "Removing #{video_id} from playlists"
      REDIS.keys("playlist*:ids").each do |key|
        class_name = key.split(":")[1].capitalize
        object_id = key.split(":")[2]
        recommendable_instance = eval(class_name).find_by_id(object_id)
        recommendable_instance.playlist.remove(video_id) if recommendable_instance
      end
  end

  private

 def find_next(id)
    video_id = nil
    id_index = queue.index(id.to_s)
    video_id= queue[id_index +1] if id_index
    video_id
  end


  def find_previous(id)
    video_id = nil
    id_index = queue.index(id.to_s)
    video_id= queue[id_index - 1] if id_index && id_index > 0
    video_id
  end


  def shorten_jsons
    counter = 0
    while(size > LIMIT_JSONS)
      video_id = REDIS.lindex queue_key, counter      
      REDIS.hdel jsons_key, video_id
      self.index= self.index - 1
      counter +=1
    end
  end

  def shorten_ids
    while(size > LIMIT_IDS)
      video_id = REDIS.lpop queue_key
      REDIS.hdel jsons_key, video_id
      REDIS.srem  ids_key,   video_id
      self.index= self.index - 1
    end
  end


end

