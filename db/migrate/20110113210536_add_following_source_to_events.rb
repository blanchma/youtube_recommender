class AddFollowingSourceToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :source, :string
    add_column :events, :following_id, :integer
  end

  def self.down
    remove_column :events, :source
    remove_column :events, :following_id
  end
end

