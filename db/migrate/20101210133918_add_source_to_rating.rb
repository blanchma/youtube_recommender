class AddSourceToRating < ActiveRecord::Migration
  def self.up
    add_column :ratings, :source, :string
  end

  def self.down
    remove_column :ratings, :source
  end
end
