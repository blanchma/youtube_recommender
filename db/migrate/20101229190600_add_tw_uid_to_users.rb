class AddTwUidToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :tw_uid, :string
    add_column :users, :tw_token, :string
    add_column :users, :tw_secret, :string
  end

  def self.down
    remove_column :users, :tw_uid
    remove_column :users, :tw_token
    remove_column :users, :tw_secret
  end
end
