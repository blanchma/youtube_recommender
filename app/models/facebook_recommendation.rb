class FacebookRecommendation < ActiveRecord::Base

  belongs_to :user
  belongs_to :video
  has_one :recommendation_event

  after_create :check_if_watched, :create_recommendation_event

  attr_accessor :follower, :following

  scope :not_watched, where("watched=false OR watched is null")

  def follower
    if self.mynewtv_id
      return user.follower?(self.mynewtv_id)
    else
      return false
    end
  end

  def following
    if self.mynewtv_id
      return  user.following?(self.mynewtv_id)
    else
      return false
    end

  end

  def self.pop_for(user)

    build_stack(user)

    #Extend time to die of FacebookRecs Queueu
    REDIS.expire recs_flag_key(user), 3000

    id_rec = pop_a_recommendation(user)
    return nil if id_rec.nil?

    recommendation =  FacebookRecommendation.find id_rec

    if recommendation.mynewtv_id.nil?
      friend_mynewtv = User.find_by_fb_uid recommendation.friend_id
      if friend_mynewtv
        recommendation.mynewtv_id = friend_mynewtv.id
        recommendation.save
      end
    end


    video = Video.find recommendation.video_id
    video.from = 'facebook'
    #video.friend_id = recommendation.friend_id

    video.more = recommendation
    video
  end


  def self.empty_for? user
    # user.facebook_recommendations.not_watched.size == 0
    build_stack(user)
    REDIS.llen(recs_ids_key(user)) == 0
  end

  def self.recs_ids_key(u=user)
    "user:#{u.id}:fb_recs_ids"
  end

  def self.recs_flag_key(u=user)
    "user:#{u.id}:fb_recs_flag"
  end

  def check_if_watched
    if was_watched?
      update_attribute(:watched, true)
    else
      update_attribute(:watched, false)
    end
  end

  def was_watched?
    FacebookRecommendation.watched_for?(self.user, self.video_id)
  end

  def self.clear_for(user)
    REDIS.del recs_flag_key(user)
    REDIS.del recs_ids_key(user)
  end

  def as_json(options={})
    extra_methods = [
      :follower,
    :following ]
    json_object = super
    extra_methods.each {|m| json_object[m] = send(m)}

    json_object
  end


  protected

  def self.pop_a_recommendation(user)
    REDIS.lpop recs_ids_key(user)
  end

  def self.watched_for? (user, video_id)
    watched_videos =  REDIS.sunion user.watched_key, user.hated_key, user.playlist.ids_key, user.screen_list_key
    watched_videos.include? video_id
  end



  def self.build_stack(user)
    unless REDIS.exists recs_flag_key(user)
      user.facebook_recommendations.not_watched.each do |rec|
        REDIS.rpush recs_ids_key(user), rec.id  unless watched_for?(user, rec.video_id)
      end
      REDIS.setex recs_flag_key(user), 3000, true
      return true
    end

    return false
  end

  def create_recommendation_event
      puts "id= #{self.id}"
    rec_event= RecommendationEvent.new(:source => "facebook", :video_id => video.id,
    :from_name => friend_username, :from_external_id => friend_id, :to_name => user.nickname, :to_mtv_id => user.id, :to_external_id => user.fb_uid, :recommendation_id => self.id)
    rec_event.from_mtv_id=mynewtv_id if mynewtv_id
    puts "rec_id = #{rec_event.recommendation_id}"
    saved = rec_event.save
  end


end

