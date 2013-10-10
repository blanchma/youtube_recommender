class VideoWordsIdf < ActiveRecord::Migration
  def self.up
    add_column :video_words, :idf, :float, :default => 0.0
  end

  def self.down
    remove_column :video_words, :idf
  end
end
