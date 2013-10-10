class UsersAddPhraseCacheUpdated < ActiveRecord::Migration
  def self.up
    add_column :users, :phrase_cache_updated_at, :integer
  end

  def self.down
    remove_column :users, :phrase_cache_updated_at
  end
end
