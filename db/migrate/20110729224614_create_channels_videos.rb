class CreateChannelsVideos < ActiveRecord::Migration
  def self.up
     create_table :channeled_videos do |t|
      t.integer :channel_id
      t.integer :video_id
      t.integer :rating
      t.string :comment
      t.integer :views
      t.timestamps
    end
  end

  def self.down
      drop_table :channeled_videos
  end
end
