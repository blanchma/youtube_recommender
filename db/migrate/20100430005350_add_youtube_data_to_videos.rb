class AddYoutubeDataToVideos < ActiveRecord::Migration
  def self.up
    remove_column :videos, :tags
    
    add_column :videos, :description,    :string
    add_column :videos, :keywords,       :string
    add_column :videos, :keywords_count, :integer
                                         
    add_column :videos, :duration,       :integer
    add_column :videos, :racy,           :boolean
    add_column :videos, :published_at,   :time
    add_column :videos, :categories,     :string
    add_column :videos, :author,         :string
    add_column :videos, :thumb_url,      :string
    add_column :videos, :thumb_big_url,  :string
    
    add_column :videos, :rating_min,     :integer, :default => 1
    add_column :videos, :rating_max,     :integer, :default => 5
    add_column :videos, :rating_avg,     :float
    add_column :videos, :rating_count,   :integer
    add_column :videos, :view_count,     :integer
    add_column :videos, :favorite_count, :integer
    
    add_index :videos, :youtube_id, :unique => true
  end

  def self.down
    remove_index :videos, :column => :youtube_id
    add_column :videos, :tags, :string
    
    remove_column :videos, :favorite_count
    remove_column :videos, :view_count
    remove_column :videos, :rating_count
    remove_column :videos, :rating_avg
    remove_column :videos, :rating_max
    remove_column :videos, :rating_min
    remove_column :videos, :thumb_big_url
    remove_column :videos, :thumb_url
    remove_column :videos, :author
    remove_column :videos, :description
    remove_column :videos, :keywords_count
    remove_column :videos, :keywords
    remove_column :videos, :categories
    remove_column :videos, :published_at
    remove_column :videos, :racy
    remove_column :videos, :duration
  end
end
