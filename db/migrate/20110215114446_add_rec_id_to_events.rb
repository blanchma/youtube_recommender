class AddRecIdToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :recommendation_id, :integer
  end

  def self.down
    remove_column :events, :recommendation_id
  end
end

