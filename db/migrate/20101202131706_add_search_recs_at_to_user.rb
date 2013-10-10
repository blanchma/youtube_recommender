class AddSearchRecsAtToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :search_recs_at, :timestamp
  end

  def self.down
    remove_column :users, :search_recs_at
  end
end
