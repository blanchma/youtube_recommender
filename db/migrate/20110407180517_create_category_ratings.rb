class CreateCategoryRatings < ActiveRecord::Migration
  def self.up
    create_table :category_ratings do |t|
      t.integer :user_id
      t.integer :category_id
      t.string :action
      t.integer :video_id
      t.timestamps
    end
  end

  def self.down
    drop_table :category_ratings
  end
end

