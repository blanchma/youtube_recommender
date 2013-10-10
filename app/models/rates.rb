class Rates < ActiveRecord::Base
  set_table_name 'user_rates'

  belongs_to :scoreable, :polymorphic => true

  def add(rating)
    video_score = rating.video_score
    logger.info "Video score to add to rates is #{video_score}"
    if rating.hated?
      calculate_avg_hated video_score
  elsif rating.liked?
      calculate_avg_liked video_score
    elsif rating.watched?
      calculate_avg_watched video_score
    else
      #raise ArgumentError
    end
    self.save
  end

  def calculate_avg_liked(new_score)
    self.avg_liked = (self.avg_liked + new_score) / (self.likes+1)
    self.likes+=1
  end

  def calculate_avg_hated(new_score)    
    self.avg_hated = (self.avg_hated + new_score) / (self.hates+1)
    self.hates+=1
  end

  def calculate_avg_watched(new_score)
    self.avg_watched = (self.avg_watched + new_score) / (self.views+1)
    self.views+=1
  end



end

