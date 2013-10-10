class CreateRatings < ActiveRecord::Migration
  def self.up
    create_table :ratings do |t|
      t.integer :user_id
      t.integer :video_id
      t.string  :action
      t.timestamps
    end
    add_index :ratings, :user_id
  end

  def self.down
    remove_index :ratings, :user_id
    drop_table :ratings
  end
end
