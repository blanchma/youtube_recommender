class AddCountToPost < ActiveRecord::Migration
  def self.up
    add_column :posts, :count, :integer, :default => 0

  end

  def self.down
    remove_column :posts, :count
  end
end
