class AddLinkAndEmailToFacebookRecommedantion < ActiveRecord::Migration
  def self.up
    add_column :facebook_recommendations, :friend_link, :string
    add_column :facebook_recommendations, :friend_email, :string
  end

  def self.down
    remove_column :facebook_recommendations, :friend_link
    remove_column :facebook_recommendations, :friend_email
  end
end

