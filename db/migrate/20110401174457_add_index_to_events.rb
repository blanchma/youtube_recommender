class AddIndexToEvents < ActiveRecord::Migration
  def self.up
    add_index :events, :from_mtv_id
    add_index :events, :to_mtv_id
  end

  def self.down
    remove_index :events, :from_mtv_id
    remove_index :events, :to_mtv_id
  end
end

