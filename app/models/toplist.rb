class Toplist

  #Devuelve un video listo para ver de una lista que constantemente se reconstruye
  #con mejores videos evaluados segun YT y con un indice de variabilidad obtenido de la categoria

  #NOTA: evaluar view_scores and rating_scores en el ORDER de Rating

  attr_accessor :user

  def initialize (user=nil)
    @user =  user
  end

  def recommend
    video = false
    time = Benchmark.realtime do
      not_watched = REDIS.sdiff ids_key, "users:#{user.id}:watched", "users:#{user.id}:skipped", "users:#{user.id}:hated",user_recommended_key, user.playlist.ids
      puts "Toplist videos not_watched = #{not_watched}"
      video = not_watched.first unless not_watched.nil? || not_watched.size == 0
      user_watched(video)
    end
    Rails.logger.info "Toplist take #{(time*1000.to_i)} ms to select a top video for #{user.email}"
    video
  end

  def user_watched vid
    REDIS.sadd user_recommended_key, vid
    REDIS.expire user_recommended_key, 120
  end

  def peek(limit=1)
    REDIS.lrange queue_key, 0, limit
  end

  def ids
    REDIS.smembers ids_key
  end


  def json_for id
    REDIS.hget jsons_key, id
  end

  def score_for id
    Toplist.score_for id
  end

  def self.score_for id
    REDIS.hget "toplist:scores", id
  end

  def push id, score
    return false if ids.include? id.to_s
    json = load_video(id).to_json
    REDIS.pipelined do
      REDIS.lpush queue_key, id
      REDIS.hset jsons_key, id, json
      REDIS.hset "toplist:scores", id, score
      REDIS.sadd  ids_key, id
    end
    while size > 50
      remove bottom
    end

    return true
  end

  def size
    ids.size
  end

  def empty?
    ids.empty?
  end

  def remove id
    REDIS.pipelined do
      REDIS.lrem queue_key, 0, id
      REDIS.hdel jsons_key, id
      REDIS.hdel "toplist:scores", id
      REDIS.srem ids_key, id
    end
  end

  def clear
    REDIS.pipelined do
      REDIS.del queue_key
      REDIS.del jsons_key
      REDIS.del "toplist:scores"
      REDIS.del ids_key
    end
  end

  def load_video(id)
    video = Video.find(id)
    video.from          = 'toplist'
    video.score         = Toplist.score_for id
    video.phrases_score = 'not for top videos'
    video.views_score   = Video.views_score_for id
    video.rating_score  = Video.rating_score_for id
    video.p_neutral     = 'not for top videos'

    video
  end


  def score_video(video_id)
    score = (avg_phrase_score_for(video_id) * PHRASES_SCORE_COEFFICIENT) +
    (Video.views_score_for(video_id) * VIEWS_SCORE_COEFFICIENT) +
    (Video.rating_score_for(video_id) * RATING_SCORE_COEFFICIENT)
  end

  def min_score
    scores = REDIS.hvals "toplist:scores"
    return 0 if scores.empty?
    scores.sort! {|x,y| y.to_f <=> x.to_f }
    scores.last
  end

  def bottom
    scores = REDIS.hgetall "toplist:scores"
    return nil if scores.empty?
    sorted =scores.sort {|x,y| y[1].to_f <=> x[1].to_f }
    sorted.last[0]
  end

  def max_score
    scores = REDIS.hvals "toplist:scores"
    return 0 if scores.empty?
    scores.sort! {|x,y| y.to_f <=> x.to_f }
    scores.first
  end

  def top
    scores = REDIS.hgetall "toplist:scores"
    return nil if scores.empty?
    sorted = scores.sort {|x,y| y[1].to_f <=> x[1].to_f }
    sorted.first[0]
  end

  private

  def avg_phrase_score_for vid
    phrases_scores= PhraseScore.for_video_id vid

    scores = phrases_scores.collect do |ps|
      ps.score.to_f
    end

    avg_phrase_score = 0
    avg_phrase_score = Math.tanh(scores.sum/scores.size) if scores.size > 0
    Rails.logger.info "Avg PhraseScore: #{avg_phrase_score} in Toplist"
    #puts "scores_deviation_from_neutral/1 is #{scores_deviation_from_neutral/1}"
    #puts "avg phrase score is #{avg_phrase_score}"

    avg_phrase_score
  end

  def queue_key
    "toplist:queue"
  end

  def ids_key
    "toplist:ids"
  end

  def jsons_key
    "toplist:jsons"
  end

  def scores_key
    "toplist:scores"
  end

  def user_recommended_key
    "toplist:user:#{user.id}:recommended"
  end

end

