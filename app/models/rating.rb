class Rating < ActiveRecord::Base
  belongs_to :user
  belongs_to :video
  belongs_to :channel

  attr_accessor :rec_id
  #attr_protected :action

  validates :action,   :inclusion => ['liked','hated', 'watched']

  scope :newest,  order('created_at DESC')
  scope :watched, where('action="watched"')
  scope :liked,   where('action="liked"')
  scope :hated,   where('action="hated"')
  scope :voted,   where(:action => ['hated', 'liked'])
  scope :most_liked, select("r.video_id, (v.views_score + v.rating_score) as score  ").where("r.action = 'liked' AND r.video_id = v.id").group("video_id").order("score DESC, r.updated_at DESC").from("ratings r, videos v").limit(20)  
  scope :before,  lambda {|rating_id| newest.where('id < ?', rating_id)}
  scope :before_with,  lambda {|rating_id| newest.where('id <= ?', rating_id)}
  scope :after,  lambda {|rating_id| where('id > ?', rating_id)}
  scope :on_date, lambda {|date| where('created_at BETWEEN ? AND ?', date-1, date+1) }
  scope :not_from_channel, where("channel_id IS NULL")

  after_create  :update_playlist_index
  after_create  :update_recommendations_status, :create_like_event
  after_save :update_scores, :update_redis_cache

  def liked?
    action == 'liked'
  end

  def hated?
    action == 'hated'
  end

  def watched?
    action == 'watched'
  end

  def self.percent_liked(date)
    liked   = Rating.liked.on_date(date).count.to_f
    total = Rating.on_date(date).count
    if total == 0
      0
    else
      (liked.to_f / total)*100
    end
  end

  def self.average_percent_liked(start_date, finish_date)
    results = (start_date..finish_date).collect {|d| percent_liked(d)}
    results.average
  end

  def update_scores    
    return unless self.action_changed? && (self.liked? || self.hated?)

    if user && channel && channel.user_id == user_id
      if action == 'liked'
        channel.like_video!(video)        
        channel.playlist.replace_video(self.video)
      end
      if action == 'hated'
        channel.hate_video!(video)
        channel.playlist.remove(self.video)  
        #if channel.videos.exists? video
          
      end
     CategoryScore.add(channel, self)
     video.rating = self.action
     
    elsif user
      if action == 'liked'
        user.like_video!(video)        
      end
      if action == 'hated'
        user.hate_video!(video)
      end
      CategoryScore.add(user, self)
      video.rating = self.action
      user.playlist.replace_video(self.video)
    else
      
    end

  end

  def update_redis_cache
    logger.debug "SAVING TO REDIS CACHE OF WATCHED IDS!"
    return unless user
   if hated?
      REDIS.sadd user.hated_key, video_id
      REDIS.srem user.liked_key, video_id
    elsif liked?
      REDIS.sadd user.liked_key, video_id
      REDIS.srem user.hated_key, video_id
    else
      REDIS.sadd user.watched_key, video_id
      REDIS.srem user.hated_key, video_id
      REDIS.srem user.liked_key, video_id
    end

  end

  def update_playlist_index  
    user.playlist.update_index(video_id)     if user && user_id == user_channel_id
  end

  def update_recommendations_status
    if source == 'facebook'
      fr = FacebookRecommendation.find rec_id
      fr.update_attribute(:watched, true)
      logger.info "[#{fr.id}] #{video.title} set watched in FacebookRecommendation for #{user.email}"
    end
  end

  def create_like_event
    if user && liked? && !channel?
      like_event = LikeEvent.create(:video_id => self.video.id, :source => "mynewtv",
      :from_name => user.nickname, :from_mtv_id => user.id)      
      logger.info "Created a LikeEvent from #{like_event.from_name} about #{like_event.video.title}" if like_event
    end
  end

  def channel?
    !channel.nil?  
  end


end

