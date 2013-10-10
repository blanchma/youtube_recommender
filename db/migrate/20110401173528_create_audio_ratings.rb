class CreateAudioRatings < ActiveRecord::Migration
  def self.up
    create_table :audio_ratings do |t|
      t.integer :user_id
      t.integer :audio_comment_id
      t.string  :action
      t.timestamps
    end
    add_index :audio_ratings, :audio_comment_id
  end

  def self.down
    remove_index :audio_ratings, :audio_comment_id
    drop_table :audio_ratings
  end
end
