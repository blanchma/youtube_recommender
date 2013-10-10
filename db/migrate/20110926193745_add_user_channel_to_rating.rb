class AddUserChannelToRating < ActiveRecord::Migration
  def self.up
    add_column :ratings, :user_channel_id, :integer
    add_column :ratings, :category_id, :integer
  end

  def self.down
    remove_column :ratings, :user_channel_id
    remove_column :ratings, :category_id
  end
end
