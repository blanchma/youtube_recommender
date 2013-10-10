class AddIndexToVideos < ActiveRecord::Migration
  def self.up
    unless index_exists? :videos, :category_id
      add_index :videos, :category_id
      add_index :videos, :created_at
      add_index :videos, :title
      add_index :videos, :description
      add_index :videos, :keywords
    end
  end

  def self.down
    remove_index :videos, :category_id
    remove_index :videos, :created_at
    remove_index :videos, :title
    remove_index :videos, :description
    remove_index :videos, :keywords
  end
end

