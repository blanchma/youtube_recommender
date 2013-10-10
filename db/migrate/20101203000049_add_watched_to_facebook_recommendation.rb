class AddWatchedToFacebookRecommendation < ActiveRecord::Migration
  def self.up
    add_column :facebook_recommendations, :watched, :boolean, :default => false
  end

  def self.down
    remove_column :facebook_recommendations, :watched
  end
end
