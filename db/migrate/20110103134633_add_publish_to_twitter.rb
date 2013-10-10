class AddPublishToTwitter < ActiveRecord::Migration
  def self.up
    add_column :users, :publish_to_tw, :boolean
    rename_column :users, :publish_likes, :publish_to_fb
  end

  def self.down
    remove_column :users, :publish_to_tw
    rename_column :users, :publish_to_fb, :publish_likes
  end
end
