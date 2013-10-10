class PhrasesAddTimestamps < ActiveRecord::Migration
  def self.up
    add_column :phrases, :created_at, :datetime
    add_column :phrases, :updated_at, :datetime
  end

  def self.down
    remove_column :phrases, :updated_at
    remove_column :phrases, :created_at
  end
end
