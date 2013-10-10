class AddIndexToChanneledVideos < ActiveRecord::Migration
  def self.up
      add_index :channeled_videos, :video_id
      add_index :channeled_videos, :channel_id      
  end

  def self.down
      remove_index :channeled_videos, :video_id
      remove_index :channeled_videos, :channel_id
  end
end
