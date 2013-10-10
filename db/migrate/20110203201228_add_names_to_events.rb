class AddNamesToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :from_name, :string
    add_column :events, :to_name, :string
  end

  def self.down
    remove_column :events, :to_name
    remove_column :events, :from_name
  end
end
