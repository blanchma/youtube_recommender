class CreateMynewtvRecommendations < ActiveRecord::Migration
  def self.up
    create_table :mynewtv_recommendations do |t|
      t.integer :user_id
      t.integer :video_id      
      t.timestamps
    end
  end

  def self.down
    drop_table :mynewtv_recommendations
  end
end
