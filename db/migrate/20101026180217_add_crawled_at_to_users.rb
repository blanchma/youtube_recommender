class AddCrawledAtToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :crawled_at, :timestamp, :default => Time.now
  end

  def self.down
    remove_column :users, :crawled_at
  end
end
