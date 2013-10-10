class PhraseScore < ActiveRecord::Base


  belongs_to :scoreable, :polymorphic => true
  belongs_to :phrase

  validates :scoreable_id,   :presence => true
  validates :phrase_id, :presence => true

  scope :neutral,     where(:total => 0)
  scope :voted,       where('total > 0')
  scope :with_phrase, joins(:phrase).select('phrase_scores.*, phrases.idf, phrases.text, phrases.videos_count')

  scope :with_video,  joins('join phrases_videos on phrases.id=phrases_videos.phrase_id')
  scope :for_video_id,   lambda {|video_id| with_phrase.with_video.where(['phrases_videos.video_id=?', video_id])}

  scope :in_videos,   with_phrase.where('phrases.videos_count>0')

  scope :for_search,  voted.order('p_weighted_cache DESC')#voted.in_videos.order('p_weighted_cache DESC').

  min_videos_count = 0 if Rails.env == "development"
  min_videos_count = 5 if Rails.env == "production"
  scope :most_liked, select("phrase_id, text, sum(likes - hates) as likeness").where("phrase_id IN (SELECT id FROM phrases WHERE videos_count > #{min_videos_count})").group("phrase_id").order("likeness DESC").limit(10)
  scope :recently, select("DISTINCT scoreable_id, scoreable_type").where("updated_at > '#{2.day.ago.strftime("%Y-%m-%d %H:%M:%S")}'").order("updated_at")
  #validates :text, :length => {:minimum => 2}, :stopword_filter => true


  before_create :set_text_from_phrase
  before_save   :update_stats
  after_save    :update_redis
  after_create  :set_seed


  def idf
    logger.debug 'loading phrase for IDF...'
    phrase.idf
  end

  def voted?
    total > 0
  end

  def dupe?
    scoreable.phrase_scores.where(:phrase_id => phrase_id).count > 1
  end


  def self.score_for(scoreable, phrase_id)
    redis_score = REDIS.hget "scoreable:#{scoreable.class.to_s.downcase}:#{scoreable.id}:p_scores", phrase_id
    if redis_score.nil? || redis_score == ""
      phrase_score = scoreable.phrase_scores.find_by_phrase_id(phrase_id)
      return nil if phrase_score.nil?
      timer "       Calculating phrase_score #{phrase_id} " do
        redis_score = phrase_score.calculate_score
      end
    end
    suppress_until = suppress?(scoreable, phrase_id)

    if suppress_until < 1
      p_unseen = 1
  else
      p_unseen = 1 - (suppress_until / SUPPRESS_SECONDS)
    end

    (redis_score.to_f * p_unseen).to_s
  end


  def score   
    if redis_score.nil? || redis_score == 0
      update_stats
      update_redis
    end
    redis_score.to_f * p_unseen
  end

  def calculate_score
    new_score = 0
    timer "calculating score for #{id}:#{text} " do
      new_score = p_weighted * p_rare
    end
    new_score
  end

  def update_p_like
    #puts "update_p_like"
    self.total  = likes+hates
    #BEFORE was /10
    self.weight = total.to_f/8

    if total == 0
      self.p_like = 0
    elsif total == 1
      self.p_like = likes.to_f/1.5
    else
      self.p_like = likes.to_f/total
    end
  end

  def p_rare
    #puts "p_rare"
    update_p_rare_cache if self.p_rare_cache.nil? || self.p_rare_cache == 0
    self.p_rare_cache
  end

  def update_p_rare_cache
    #puts "update_p_rare"
    maximum_idf = Phrase.max_idf
    #BEFORE was without Math.tanh
    self.p_rare_cache = Math.tanh(idf / maximum_idf )
  end


  def p_weighted
    #puts "p_weighted_cache"
    update_p_weighted_cache if self.p_weighted_cache.nil? || self.p_weighted_cache == 0
    self.p_weighted_cache
  end

  def update_p_weighted_cache
    #puts "update_p_weighted_cache"
    unless scoreable.nil?
      avg_subject = scoreable.avg_p_like
    else
      avg_subject = 0.5
    end
    self.p_weighted_cache =  avg_subject + (p_tanh - avg_subject)
  end

  def p_tanh
    #puts "p_tanh"
    update_p_tanh_cache  if self.p_tanh_cache.nil? || self.p_tanh_cache == 0
    self.p_tanh_cache
  end

  def update_p_tanh_cache
    unless scoreable.nil?
      avg_subject = scoreable.avg_p_like
    else
      avg_subject = 0.4
    end

    if voted?
      new_p_tanh = weight * p_like + (1-weight) *  avg_subject
    else
      new_p_tanh =  0.1
    end
    self.p_tanh_cache = new_p_tanh
  end

  # Suppression methods
  SUPPRESS_SECONDS = 172800 # 48 hours
  def suppress!
    #self.suppress_until   = Time.now.to_i + SUPPRESS_SECONDS
    #update_redis
    return false if source == "seed"
    return REDIS.setex phrase_score_suppress_key, SUPPRESS_SECONDS, true
  end

 
  def p_unseen
    #puts "p_unseen"
    #return 1 unless suppress_until
    suppress_until = REDIS.ttl phrase_score_suppress_key
    #logger.info "ttl of #{self.text}: #{suppress_until}"
    return 1 if suppress_until < 1
    p_unseen = 1 - (suppress_until / SUPPRESS_SECONDS.to_f)
    #logger.info "p_unseen of #{self.text}: #{p_unseen}"
    p_unseen
  end

  def set_text_from_phrase
    unless text
      self.text = phrase.text
    end
  end

  def update_stats
    update_p_like
    update_p_rare_cache
    update_p_tanh_cache
    update_p_weighted_cache
  end

  def update_redis
    REDIS.hset phrase_score_key, phrase_id, calculate_score
  end

  def redis_score
    REDIS.hget(phrase_score_key, phrase_id)
  end

  def destroy
    REDIS.hdel(phrase_score_key, phrase_id)
    remove_seed
    super
  end

  def self.suppress(scoreable, phrase_id)
    return if REDIS.sismember "scoreable:#{scoreable.class.to_s.downcase}-#{scoreable.id}:seeds", phrase_id  
    REDIS.setex "scoreable:#{scoreable.class.to_s.downcase}-#{scoreable.id}:p:#{phrase_id}:sups", SUPPRESS_SECONDS, true
  end
  
  def self.suppress?(scoreable, phrase_id)
      REDIS.ttl "scoreable:#{scoreable.class.to_s.downcase}-#{scoreable.id}:p:#{phrase_id}:sups"
  end

  def self.compress(subject)
          phrase_scores = subject.phrase_scores.sort_by(&:score)
          likest = phrase_scores.first(500).collect.each {|p| p.id}
          hatest = phrase_scores.last(500).collect.each {|p| p.id}
          suppressed = phrase_scores.collect.each {|p| p.id if p.p_unseen < 1}
          keep = suppressed + hatest + likest
          keep = keep.uniq - [nil]
          phrase_scores_ids = phrase_scores.collect.each {|p| p.id}
          remove = phrase_scores_ids - keep
          puts "Compress #{remove.size} phrases from #{subject.class.name} - #{subject.id}"
          remove.each do |id|
            PhraseScore.destroy id
          end
  end

  private
  def phrase_score_key
    "scoreable:#{scoreable_type.downcase}-#{scoreable_id}:p_scores"
  end

  def phrase_score_suppress_key
    "scoreable:#{scoreable_type.downcase}-#{scoreable_id}:p:#{phrase_id}:sups"
  end

  def seed?
     REDIS.sismember "scoreable:#{scoreable.class.to_s.downcase}-#{scoreable.id}:seeds", phrase_id
  end

  def set_seed
    if source == "seed"  
      REDIS.sadd "scoreable:#{scoreable.class.to_s.downcase}-#{scoreable.id}:seeds", phrase_id
    end
  end

  def remove_seed
    if source == "seed"  
      REDIS.srem "scoreable:#{scoreable.class.to_s.downcase}-#{scoreable.id}:seeds", phrase_id
    end
  end 



end

