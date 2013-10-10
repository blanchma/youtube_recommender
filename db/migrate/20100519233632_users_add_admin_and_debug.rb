class UsersAddAdminAndDebug < ActiveRecord::Migration
  def self.up
    add_column :users, :admin, :boolean, :default => false
    add_column :users, :debug, :boolean, :default => false
  end

  def self.down
    remove_column :users, :debug
    remove_column :users, :admin
  end
end
