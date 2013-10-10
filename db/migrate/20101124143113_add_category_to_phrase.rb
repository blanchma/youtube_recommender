class AddCategoryToPhrase < ActiveRecord::Migration
  def self.up
    add_column :phrases, :is_category, :boolean
  end

  def self.down
    remove_column :phrases, :is_category
  end
  
end

