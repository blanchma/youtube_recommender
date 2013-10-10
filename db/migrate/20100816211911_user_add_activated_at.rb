class UserAddActivatedAt < ActiveRecord::Migration
  def self.up
    add_column :users, :activated_at, :datetime, :default => nil
  end

  def self.down
    remove_column :users, :activated_at
  end
end
