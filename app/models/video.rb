
class Video < ActiveRecord::Base
  attr_accessor :score, :from, :more, :rating
  attr_reader :has_audio_comments

  define_index do
    indexes title
    indexes description
    indexes keywords, :as => :tags

    order_by "created_at DESC, rating_score DESC, views_score DESC"
    set_property :field_weights => {
      :subject => 10,
      :tags    => 6,
      :content => 3
    }
      set_property :delta => true

  end



  belongs_to :category

  #has_and_belongs_to_many :youtube_users
  has_and_belongs_to_many :phrases

  has_many :ratings, :dependent => :destroy
  has_many :recommendation_events, :dependent => :destroy
  has_many :posts, :dependent => :destroy
  has_many :like_events, :dependent => :destroy
  has_many :facebook_recommendations, :dependent => :destroy

  has_many :audio_comments
  
  has_many :channeled_videos
  has_many :channels, :through => :channeled_videos

  validates :youtube_id,  :uniqueness => true, :on => :create
  validates :youtube_id,  :presence   => true
  validates :title,       :presence   => true

  before_create     :add_phrases, :set_category

  before_save       :calculate_scores
  after_save        :update_phrase_count,:add_to_redis

  #before_destroy    :remove_from_redis

  scope :best_scores, order('views_score DESC, rating_score DESC').limit(500)

  def keywords_ary
    keywords ? keywords.split(/\,\s+/) : []
  end

  def title_ary
    title ? title.downcase.gsub(/[^A-Za-z0-9\s]/, '').split(/\s+/) : []
  end

  def has_audio_comments
    !audio_comments.empty?
  end

  def word_pairs
    combos = []
    words_ary.each_with_index do |w, idx|
      next if idx == words_ary.size - 1
      combos << w + ' ' + words_ary[idx+1]
    end
    combos.uniq
  end

  def words_ary
    @words_ary ||= (keywords_ary + title_ary)
  end

  def words
    @words ||= words_ary.join(', ')
  end

  def as_json(options={})
    extra_methods = [
      :from,
      :more,
      :words_debug,
      :debug_result_rows,
      :phrase_scores_searched,
      :phrases_score,
      :views_score,
      :rating_score,
      :score,
      :category_score,
      :query,
      :queryWords,
      :rating,
    :has_audio_comments ]
    json_object = super
    extra_methods.each {|m| json_object[m] = send(m)}

    json_object
  end
  
  
  def rating_from(user)
    ratings = user.ratings.voted
    @rating = ratings.last.action unless ratings.empty?    
    
    @rating    
  end

  #---------------------------------
  # Methods for calculating scores in search
  # results
  #---------------------------------


  attr_accessor :phrase_scores_searched, :category_score
  attr_accessor :words_debug, :debug_result_rows
  attr_accessor :p_neutral, :phrases_score, :query, :queryWords
  # for user channel playlists...
  attr_accessor :rating_id



  def self.views_score_for(vid)
    views_score =  (REDIS.get "video:#{vid}:views_score").to_f
    unless views_score
      puts "seting in redis views_score"
      video = Video.select("views_score").find vid
      views_score = video.views_score
      REDIS.set "video:#{vid}:views_score", views_score
    end
    views_score
  end

  def self.set_views_score_for(vid, views_score)
    REDIS.set "video:#{vid}:views_score",  views_score
  end

  def self.rating_score_for(vid)
    rating_score = (REDIS.get "video:#{vid}:rating_score").to_f

    unless rating_score
      puts "seting in redis rating_score"
      video = Video.select("rating_score").find vid
      rating_score = video.rating_score
      REDIS.set "video:#{vid}:rating_score", rating_score
    end
    rating_score
  end

  def self.set_rating_score_for(vid, views_score)
    REDIS.set "video:#{vid}:rating_score",  views_score
  end


  def add_to_redis
      Video.set_rating_score_for id, rating_score
      Video.set_views_score_for id, views_score
  end

  def update_phrase_count
    phrases.each do |phrase|
      phrase.videos_count+=1
      phrase.save!
    end
  end

  def self.category_id_for(video_id)
    category_id = REDIS.get "video:#{video_id}:category"
    unless category_id
      vid = Video.select("category_id").find video_id
      category_id = vid.category_id
    end
    category_id
  end

  def remove_from_redis
    puts "removing... #{self.id}"
    self.phrases.select("id").each do |phrase|
      puts "phrase #{phrase.id} for video #{self.id}"
      result= REDIS.srem "phrase:#{phrase.id}:videos", self.id
      puts result
    end
    REDIS.del "video:#{id}:phrases"
    REDIS.del "video:#{id}:rating_score"
    REDIS.del "video:#{id}:views_score"
    REDIS.del "video:#{id}:category"
  end

  def calculate_scores
    if view_count < 3
      self.views_score = 0.036
    else
      self.views_score = Math.log(view_count) / Math.log(2500000)
    end
    self.rating_score = rating_avg.to_f / 5
  end

  def add_phrases
    words_ary.uniq.each do |word|
      phrase = Phrase.find_or_create_by_text(word)
      self.phrases << phrase if phrase.id
    end
  end

  def destroy
    remove_from_redis
    super
  end


  def deactivate
    logger.info "Deactivating video #{self.id}"
    remove_from_redis
  end

  def get_category
    set_category unless category
    category
  end

  def set_category(cat_id=nil)
    unless cat_id
      cat = Category.find_or_create_by_name categories
      cat_id = cat.id
    end
    self.category_id = cat_id
    REDIS.set "video:#{id}:category", cat_id
  end


  def title_ary
    title.downcase.gsub(/[^A-Za-z0-9\s]/, '').split(/\s+/)
  end

  def words_ary
    @words_ary ||= (keywords_ary + title_ary).uniq
  end

  def words
    @words ||= words_ary.join(', ')
  end

end

