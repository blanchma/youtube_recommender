class CreateVideoWords < ActiveRecord::Migration
  def self.up
    create_table :video_words do |t|
      t.string  :text
      t.integer :videos_count, :default => 0
    end
    add_index :video_words, :text, :unique => true
    
    create_table :video_words_videos, :force => true, :id => false do |t|
      t.integer :video_id
      t.integer :video_word_id
    end
    add_index :video_words_videos, :video_id
    add_index :video_words_videos, :video_word_id
  end

  def self.down
    remove_index :video_words_videos, :video_word_id
    remove_index :video_words_videos, :video_id
    
    drop_table :video_words_videos
    remove_index :video_words, :column => :text
    drop_table :video_words
  end
end
