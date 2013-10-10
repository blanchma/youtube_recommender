class RenameFriendLinkToFriendId < ActiveRecord::Migration
  def self.up
    rename_column :facebook_recommendations, :friend_link, :mynewtv_id
  end

  def self.down
    rename_column :facebook_recommendations, :mynewtv_id, :friend_link
  end
end

