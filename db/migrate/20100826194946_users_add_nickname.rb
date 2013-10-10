class UsersAddNickname < ActiveRecord::Migration
  def self.up
    add_column :users, :custom_nickname, :string
    add_index :users, :custom_nickname, :unique => true
    
    add_column :users, :private_channel, :boolean, :default => false
  end

  def self.down
    # remove_column :users, :private_channel
    remove_index :users, :custom_nickname
    remove_column :users, :custom_nickname
  end
end
