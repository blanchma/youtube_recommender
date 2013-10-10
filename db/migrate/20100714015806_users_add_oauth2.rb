class UsersAddOauth2 < ActiveRecord::Migration
  def self.up
    add_column :users, :oauth2_uid, :integer,  :limit => 8    # BIGINT unsigned / 64-bit int
    add_column :users, :oauth2_token, :string, :limit => 149  # [128][1][20] chars
    
    add_index :users, :oauth2_uid, :unique => true
  end

  def self.down
    remove_index :users,  :oauth2_uid
    
    remove_column :users, :oauth2_uid
    remove_column :users, :oauth2_token
    
  end
end
