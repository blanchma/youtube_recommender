class Phrase < ActiveRecord::Base
  $maximum_idf = nil


  has_many :relations_to, :class_name => 'Relation', :foreign_key => 'parent_id'
  has_many :relations_from, :class_name => 'Relation', :foreign_key => 'child_id'

  has_many :related_to, :through => :relations_to,   :source => :child
  has_many :related_from, :through => :relations_from, :source => :parent

  has_many                :phrase_scores, :dependent => :destroy
  has_and_belongs_to_many :videos

  before_create :custom_validate
  before_save :update_idf, :update_videos_count


  scope :to_crawl, where("last_crawled_at is NULL OR last_crawled_at < '#{3.day.ago.strftime("%Y-%m-%d %H:%M:%S")}'")

  #validates :text, :length => {:minimum => 2}, :stopword_filter => true, :uniqueness => true

  def custom_validate
    if text.nil?
      return false
    elsif text && text.length < 4
      return false
    elsif Stopwords.is?(text)
      return false 
    end
    return true
  end

  def text=(new_text)
    new_text.downcase!
    write_attribute :text, new_text
  end

  # Phrase.count_by_sql "SELECT COUNT(*) FROM phrases_videos WHERE phrase_id =#{52}"

  def update_videos_count
    self.videos_count+= 1
  end

  def recently_crawled?
    if last_crawled_at
      return last_crawled_at > 1.day.ago
    else
      return false
    end
  end

  #Why the arg total_videos=756769?
  def update_idf(total_videos=2100190)
    if videos_count < 1
      # This idf is unreal but doesn't matter cos we only use idf when we have videos associated
      self.idf = 1
    else
      #total_videos = Video.count(:all).to_f
      self.idf = Math.log(total_videos/videos_count)
    end

    $maximum_idf =  Phrase.max_idf > self.idf ? Phrase.max_idf : self.idf
  end


  def self.max_idf
    Phrase.update_max_idf if $maximum_idf.nil?
    $maximum_idf
  end

  def self.update_max_idf
    #puts "update_max_idf begin"
    time = Benchmark.realtime do
      if Phrase.count == 0
        $maximum_idf = 1
      else
        $maximum_idf = Phrase.select("idf").order("idf DESC").limit(1).first.idf
      end
    end
    #puts "update_max_idf takes #{time}"

  end




end

