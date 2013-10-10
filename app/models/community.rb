class Community < ActiveRecord::Base
  set_table_name :users
  has_many :phrase_scores, :as => :scoreable, :dependent => :destroy
  scope    :to_crawl,      where("crawled_at is NULL OR crawled_at < '#{2.day.ago.strftime("%Y-%m-%d %H:%M:%S")}'")
  
  def avg_p_like
    return @avg_p_like if @avg_p_like
    total = phrase_scores.voted.count

    if total > 0
      if ratings.voted.count > 75
        @avg_p_like = phrase_scores.voted.sum(:p_like) / total
      else
        @avg_p_like = 0.494682091928226
      end
    else
      @avg_p_like = 0.0
    end
  end


end
