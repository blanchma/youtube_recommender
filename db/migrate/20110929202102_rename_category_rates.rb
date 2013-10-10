class RenameCategoryRates < ActiveRecord::Migration
  def self.up
    rename_table :category_rates, :category_scores
    add_column :category_scores, :scoreable_type, :string
    rename_column :category_scores, :user_id, :scoreable_id
  end

  def self.down
    rename_table :category_scores, :category_rates
    drop_column :category_scores, :scoreable_type
    rename_column :category_scores, :scoreable_id, :user_id
  end
end
