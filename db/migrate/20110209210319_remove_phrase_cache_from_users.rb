class RemovePhraseCacheFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :phrase_cache_updated_at
    remove_column :users, :fb_access_token
  end

  def self.down
    add_column :users, :phrase_cache_updated_at, :integer
    add_column :users, :fb_access_token, :string
  end
end

