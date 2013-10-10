class UserAddPublishPref < ActiveRecord::Migration
  def self.up
    add_column :users, :publish_likes, :boolean, :default => true
    
    remove_column :ratings, :published
    add_column    :ratings, :to_publish, :boolean, :default => false
  end

  def self.down
    remove_column :ratings, :to_publish
    add_column    :ratings, :published, :boolean,  :default => false
    
    remove_column :users, :publish_likes
  end
end
