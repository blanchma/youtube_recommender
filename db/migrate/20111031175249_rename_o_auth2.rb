class RenameOAuth2 < ActiveRecord::Migration
  def self.up
    rename_column :users, :oauth2_token, :fb_token
    rename_column :users, :oauth2_uid, :fb_uid
  end

  def self.down
        rename_column :users, :fb_token, :oauth2_token
    rename_column :users, :fb_uid, :oauth2_uid
  end
end
