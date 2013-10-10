class AddVideoScoreToRating < ActiveRecord::Migration
  def self.up
          add_column :ratings, :video_score, :float, :default => 0
  end

  def self.down
      remove_column :ratings, :video_score
  end
end
