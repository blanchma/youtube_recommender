class AddAvgsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :avg_like, :float
    add_column :users, :avg_hate, :float
    add_column :users, :avg_watched, :float
    add_column :users, :avg_skipped, :float
  end

  def self.down
    remove_column :users, :avg_skipped
    remove_column :users, :avg_watched
    remove_column :users, :avg_hate
    remove_column :users, :avg_like
  end
end
