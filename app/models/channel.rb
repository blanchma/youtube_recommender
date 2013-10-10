class Channel < ActiveRecord::Base
  extend FriendlyId
  include Recommendable

  friendly_id :name, :use => :slugged
  attr_accessor :is_follower
  
  PUBLIC = 2
  FOLLOWERS_ONLY = 1
  PRIVATE = 0

  belongs_to :category
  belongs_to :creator, :class_name => "User", :foreign_key => "user_id"

  has_many :ratings, :foreign_key => "channel_id"
  
  has_many :follow_channels
  has_many :followers, :class_name => "User", :through => :follow_channels, :source => :follower

  has_many :channeled_videos
  has_many :videos, :through => :channeled_videos

  has_many :phrase_scores, :as => :scoreable, :dependent => :destroy
  has_many :category_scores, :as => :scoreable, :dependent => :destroy

  validates :name, :presence => true, :allow_blank => false, :length => { :within => 6..24 }
  validates :name, :uniqueness => {:scope => :user_id}  

  validate :validate_limit_channels, :validate_seed_video

  validates :name, :exclusion => { :in => %w(public kids music about-us), :case_sensitive => false,
    :message => "%{value} is reserved." }

  has_many :ratings
  
  after_create :dig_all_videos


  def videos_ordered(video_id=nil)
    videos.order("channeled_videos.created_at DESC")
  end

  
  def link
    "#{HOST}play/#{self.creator.slug}/#{self.slug}"
  end

  def validate_seed_video
    errors.add :base, "You need at least a seed video" if videos.size == 0
  end

  def validate_limit_channels
    errors.add :base, "You can't create more than five channels" if creator && creator.channels.count > 5
  end
  
  def follower?(user)
    @is_follower= self.followers.exists?(user)
    @is_follower
  end

  def likes
    self.ratings.liked.count
  end

  def hates
    self.ratings.hated.count
  end

  def count_followers
    self.followers.count
  end

  def add_seed(video_id)
    false if videos.exists? video_id
    video = Video.find_by_id video_id
    if video
      videos << video
      dig_a_video video      
      return true
    else
      return false
    end

  end

  def remove_seed(video_id)
    false unless videos.exists? video_id
    video = Video.find_by_id video_id
    if video
      videos << video
      undig_a_video video
      return true
    else
      return false
    end  
  end

  def dig_all_videos
    self.videos.each do |video|
      dig_a_video video
    end
  end

  def dig_a_video(video)
    video.phrases.each do |phrase|
        phrase_score = self.phrase_scores.find_or_create_by_phrase_id phrase.id
        phrase_score.source = "seed"
        phrase_score.likes += 4
        phrase_score.save
      end    
    video.from="seed"
    self.playlist.append(video)  
  end

  def undig_a_video(video)
    video.phrases.each do |phrase|
      phrase_score = self.phrase_scores.find_by_phrase_id phrase.id
      next unless phrase_score
      phrase_score.likes -= 2
      if phrase_score.likes > 0 || phrase_score.hates > 0
        phrase_score.save
      else
        phrase_score.destroy
      end
    end
      self.playlist.remove(video)
  end

end


class LimitChannels < ActiveModel::Validator
  def validate
    if record.channels.count > 5
      record.errors[:base] << "You can't create more than five channels."
    end
  end
end
