class AddChannelToRatings < ActiveRecord::Migration

  def self.up
    add_column :ratings, :channel_id, :integer
    remove_column :channels, :likes
    remove_column :channels, :hates  
  end

  def self.down
    remove_column :ratings, :channel_id, :integer
    add_column :channels, :likes, :integer, :default => 0
    add_column :channels, :hates, :integer, :default => 0
  end
end

