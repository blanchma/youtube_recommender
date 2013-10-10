class CreateAudioComments < ActiveRecord::Migration
  def self.up
    create_table :audio_comments do |t|
      t.integer :user_id
      t.integer :video_id
      t.string :location
      t.string :title
      t.string :description
      t.integer :rating, :default => 0
      t.float :size
      t.integer :listen_count, :default => 0
      t.integer :hates, :default => 0
      t.integer :likes, :default => 0
      t.boolean :public
      t.timestamps
    end
    add_index :audio_comments, :video_id
  end

  def self.down
    remove_index :audio_comments, :video_id
    drop_table :audio_comments
  end
end

