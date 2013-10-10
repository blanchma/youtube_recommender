class VideosAddViewsScoreAndRatingScore < ActiveRecord::Migration
  def self.up
    add_column :videos, :rating_score, :float
    add_column :videos, :views_score,  :float
    
    Video.reset_column_information
    i = 0
    total = (Video.count / 1000)+1
    Video.find_in_batches do |videos|
      i = i+1
      puts "batch #{i} / #{total}"
      videos.each {|v| v.save!}
    end
  end

  def self.down
    remove_column :videos, :views_score
    remove_column :videos, :rating_score
  end
end
