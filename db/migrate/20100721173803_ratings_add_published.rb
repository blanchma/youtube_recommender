class RatingsAddPublished < ActiveRecord::Migration
  def self.up
    add_column :ratings, :published, :boolean, :default => false
  end

  def self.down
    remove_column :ratings, :published
  end
end
