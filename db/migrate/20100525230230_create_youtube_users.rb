class CreateYoutubeUsers < ActiveRecord::Migration
  def self.up
    create_table :youtube_users do |t|
      t.string :username

      t.timestamps
    end
    
    create_table :videos_youtube_users, :id => false do |t|
      t.integer :youtube_user_id
      t.integer :video_id
    end
    add_index :videos_youtube_users, :youtube_user_id
    add_index :videos_youtube_users, :video_id
  end

  def self.down
    remove_index :videos_youtube_users, :youtube_user_id
    remove_index :videos_youtube_users, :video_id
    drop_table :videos_youtube_users
    drop_table :youtube_users
  end
end
