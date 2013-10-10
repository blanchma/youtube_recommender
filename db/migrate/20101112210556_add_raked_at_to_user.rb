class AddRakedAtToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :raked_at, :timestamp, :default => Time.now
  end

  def self.down
    remove_column :users, :raked_at
  end
end
