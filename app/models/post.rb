class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :video
  
  validate :user_id,  :presence => true
  validate :video_id, :presence => true

  

  
  scope :unpublished, where(:published => false)
  scope :published,   where(:published => true)
  scope :oldest,      order('created_at')
  scope :latest,      order('created_at DESC')
  
  after_initialize :default_message
  
  attr_reader :link
  
  
  def default_message
    unless self.message
      self.message = 'Check this out!'
    end
  end
  
  def link
      "#{HOST}watch/#{video_id}"
  end
  
  def to_param
    "#{video_id}-#{video.title.gsub(/[^A-Za-z0-9]+/i, '-').first(40)}"
  end
  
  def facebook_post_params
    # it's confusing, but in the FB parlance, the caption is what appears right after the
    # username, & the caption is the big chunk of text in the middle.
    #
    # Nate Daiger <message>
    # [ image ] <caption, caption, caption
    # [ here  ]  caption, caption >
    #
    # date, MyNew.TV, etc
    {
      :message     => message,
      :name        => video.title,
      :picture     => video.thumb_url,
      :link        => link,
      :description => "You can create your own personalized channel!",
      :caption     => 'http://mynew.tv'
    }
  end
  
  def twitter_post_params
     "Check this out: #{video.title} #{link} via @mynewtv" 
  end
  
  def facebook?
    true
  end
  
  def url
    if external_id && facebook?
      user_id, story_id = external_id.split('_')
      "http://facebook.com/profile.php?id=#{user_id}&v=wall&story_fbid=#{story_id}"
    else
      nil
    end
  end
end
