class CreateFacebookRecommendations < ActiveRecord::Migration
  def self.up
    create_table :facebook_recommendations do |t|
      t.integer :user_id  
      t.string  :post_id
      t.string  :friend_id
      t.string  :friend_username
      t.string  :friend_pic_url
      t.string  :youtube_id
      t.integer :video_id      
      t.timestamps
    end
  end

  def self.down
    drop_table :facebook_recommendations
  end
end
