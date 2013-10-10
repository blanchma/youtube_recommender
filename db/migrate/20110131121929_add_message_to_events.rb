class AddMessageToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :from, :string
    add_column :events, :from_mtv_id, :integer
    add_column :events, :from_external_id, :string
    add_column :events, :to, :string
    add_column :events, :to_mtv_id, :integer
    add_column :events, :to_external_id, :string
    remove_column :events, :following_id
  end

  def self.down
    remove_column :events, :from
    remove_column :events, :from_mtv_id
    remove_column :events, :from_external_id
    remove_column :events, :to
    remove_column :events, :to_mtv_id
    remove_column :events, :to_external_id
    add_column :events, :following_id
  end
end

