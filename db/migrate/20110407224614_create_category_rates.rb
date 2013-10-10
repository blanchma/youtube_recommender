class CreateCategoryRates < ActiveRecord::Migration
  def self.up
    create_table :category_rates do |t|
      t.integer :user_id
      t.integer :category_id
      t.integer :likes, :default => 0
      t.integer :hates, :default => 0
      t.float :score
      t.timestamps
    end
  end

  def self.down
    drop_table :category_rates
  end
end
