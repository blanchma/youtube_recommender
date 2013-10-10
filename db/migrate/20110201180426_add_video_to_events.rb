class AddVideoToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :video_id, :integer
  end

  def self.down
    remove_column :events, :video_id
  end
end

