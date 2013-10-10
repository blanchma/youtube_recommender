class PhrasesToPhraseScores < ActiveRecord::Migration
  def self.up
    rename_table :phrases, :phrase_scores
    rename_table :video_words, :phrases
    rename_table :video_words_videos, :phrases_videos
    
    rename_column :phrases_videos, :video_word_id, :phrase_id
  end

  def self.down
    rename_column :phrases_videos, :phrase_id, :video_word_id
    rename_table :phrases_videos, :video_words_videos
    rename_table :phrases, :video_words
    rename_table :phrase_scores, :phrases
  end
end
