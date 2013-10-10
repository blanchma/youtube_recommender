class RatingsAddIndexForVideoId < ActiveRecord::Migration
  def self.up
    add_index :ratings, [:user_id, :video_id], :name => "ratings_user_id_video_id"
  end

  def self.down
    remove_index :ratings, :name => :ratings_user_id_video_id
  end
end
