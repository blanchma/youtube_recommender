class User < ActiveRecord::Base
  extend FriendlyId
  include Recommendable

  friendly_id :nickname, :use => :slugged

  attr_accessible :email, :password, :password_confirmation, :remember_me, :fb_token, :custom_nickname, :private_channel
  
  has_many :favourites,         :dependent => :destroy
  has_many :bookmarks,         :dependent => :destroy

  has_many :facebook_recommendations,         :dependent => :destroy

  has_many :ratings,       :dependent => :destroy
  has_one  :rates, :as => :scoreable, :dependent => :destroy
  has_many :phrase_scores, :as => :scoreable, :dependent => :destroy
  has_many :category_scores, :as => :scoreable, :dependent => :destroy

  has_many :posts,         :dependent => :destroy

  has_many :follower_to, :class_name => 'Follows', :foreign_key => 'followed_id'
  has_many :following_to, :class_name => 'Follows', :foreign_key => 'follower_id'

  has_many :followers, :through => :follower_to,   :source => :follower
  has_many :following, :through => :following_to, :source => :followed

  has_many :audio_comments,         :dependent => :destroy
  
  has_many :channels,         :dependent => :destroy
  
  has_many :follow_channels,         :dependent => :destroy
  has_many :following_channels, :through => :follow_channels, :source => :channel

  has_many :user_tokens,         :dependent => :destroy


  scope :active, where('activated_at IS NOT NULL')
  scope :pending, where('activated_at IS NULL')
  scope :recently_signed_in, active.where("current_sign_in_at > '#{2.day.ago.strftime("%Y-%m-%d %H:%M:%S")}'").order("current_sign_in_at")

  scope    :to_crawl,      active.where("crawled_at is NULL OR crawled_at < '#{2.day.ago.strftime("%Y-%m-%d %H:%M:%S")}'").order("crawled_at ASC")
  scope   :to_search_recs, active.select("id, fb_token, fb_uid").where("fb_token is not null").order(" search_recs_at ASC, last_sign_in_at ASC")

 
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :omniauthable,
  :encryptable, :encryptor => :sha1


  validates :email,      :presence => true, :uniqueness => true, :format => {:with => /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i}
  validates :password, :if => :password_required?,    :presence => true, :length => {:minimum => 4, :maximum => 20}, :confirmation => true



  before_create :build_rates
  after_create   :new_user_email
  before_destroy :clear_playlist

  attr_accessor :phrase_cache_updated, :is_followed, :is_following
  attr_reader :email_username



  def self.find_by_nickname(key)
    if key =~ /^\d+/
      # regular primary key
      find(key)
    else
      where(:custom_nickname => key).first
    end
  end

  def to_param
    if custom_nickname
      "#{id}-#{custom_nickname}"
    else
      "#{id}-#{email_username}"
    end

  end

  def nickname
    custom_nickname || "#{id}-#{email_username}"
  end

  def email_username
    email.split('@').first.gsub(/[^A-Za-z0-9]+/i, '-')
  end

  # Checks whether a password is needed or not. For validations only.
  # Passwords are always required if it's a new record, or if the password
  # or confirmation are being set somewhere.
  def password_required?
    if facebook? || twitter?
      false
    else
      !persisted? || !password.nil? || !password_confirmation.nil?
    end
  end

  def XXX_password_required?
    (!twitter? || !facebook? || !password.blank?) && super  
  end

  #before_oauth2_auto_create

def activated?
    activated_at?
  end

  def activate!
    self.update_attribute(:activated_at, Time.now)
  end

  #---------------------
  # Methods to help migrate from old passwords to new
  #---------------------



  def recently_crawled?
    if crawled_at
      return crawled_at > 1.day.ago
    else
      return false
    end
  end

  def new_user_email
    logger.info "Enqueueing new user email to #{self.email}"
    UserMailer.new_user(self.id).deliver
  end

  def recently_raked?
    if raked_at
      return raked_at > 5.day.ago
    else
      return false
    end
  end

  def rake_for_phrases
    Resque.enqueue(FbParseJob, self) unless recently_raked?
  end

  def search_recs_in_facebook
    if facebook?
      if search_recs_at.nil? || (Time.now.utc - search_recs_at)/60 > 60
        Resque.enqueue(SearchRecommendationsJob, id)
      end
    end
  end

  def self.search(query=nil, page=nil)
    if query
      active.select("id, email, custom_nickname, private_channel, slug").where('email LIKE ? || custom_nickname like ?', "%#{query}%", "%#{query}%"  ).paginate(:page => page, :per_page => 10)
    else
      active.select("id, email, custom_nickname, slug").scoped.paginate(:page => page, :per_page => 10)
    end
  end

  def search_following(query=nil, page=nil)
    if query
      following.select("id, email, custom_nickname, private_channel, slug").where('email LIKE ? || custom_nickname like ?', "%#{query}%", "%#{query}%"  ).paginate(:page => page, :per_page => 10)
    else
      following.select("id, email, custom_nickname, slug").scoped.paginate(:page => page, :per_page => 10)
    end
  end


  def following?(user_id)
    @is_following = following.exists? user_id
    @is_following
  end

  def search_followers(query=nil, page=nil)
    if query
      followers.select("id, email, custom_nickname, private_channel, slug").where('email LIKE ? || custom_nickname like ?', "%#{query}%", "%#{query}%"  ).paginate(:page => page, :per_page => 10)
    else
      followers.select("id, email, custom_nickname, slug").scoped.paginate(:page => page, :per_page => 10)
    end
  end

  def follower?(user_id)
    @is_follower = followers.exists? user_id
    @is_follower
  end

  def count_followers
    followers.count
  end

  def likes
    Rating.liked.where("user_channel_id = ?", self.id).count
  end

  def hates
    Rating.hated.where("user_channel_id = ?", self.id).count
  end

  def twitter_connected?
    !self.tw_uid.nil?
  end
 
  def clear_playlist
    Playlist.get(self).clear
  end

  def flaring?
    REDIS.exists("flare:#{id}:video")
  end


  def self.new_with_session(params, session)
    super.tap do |user|
      if omniauth = session[:omniauth]
        if omniauth['provider'] == "facebook"        
        fb_uid = omniauth['uid']
      elsif omniauth['provider'] == "twitter"
        tw_uid = omniauth['uid']
      else
        logger.error "Provider unknown"
      end
      end
    end
  end
  
  def apply_omniauth(omniauth)
    #add some info about the user
    self.email = omniauth['user_info']['email'] if email.nil? || email.blank?
    self.custom_nickname = omniauth['user_info']['name'] || omniauth['user_info']['nickname'] if custom_nickname.blank?
    
    unless omniauth['credentials'].blank?
      if omniauth['provider'] == "facebook"
        self.fb_token = omniauth['credentials']['token']
        self.fb_uid = omniauth['uid']
      elsif omniauth['provider'] == "twitter" 
        self.tw_token = omniauth['credentials']['token']
        self.tw_uid = omniauth['uid']
      else
        logger.error "Provider unknown"
      end
    end
    #self.confirm!# unless user.email.blank?
  end
  
def update_with_password(params={})
  params.delete(:current_password)
  self.update_without_password(params)
end	
 
   def update_without_password(params={})
        params.delete(:password)
        params.delete(:password_confirmation)

        result = update_attributes(params)
        clean_up_passwords
        result
      end


  def twitter?
    tw_token?
  end

  def facebook?
    fb_token?
  end

  def oauth2_connected?
    fb_token || tw_token  
  end

end

