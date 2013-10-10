class CreateChannels < ActiveRecord::Migration
  def self.up
    create_table :channels do |t|
      t.integer :user_id
      t.string :name
      t.string :description
      t.string :category
      t.integer :category_id
      t.integer :score, :default => 0
      t.integer :likes, :default => 0
      t.integer :hates, :default => 0
      t.integer :visits, :default => 0
      t.integer :privacy, :default => 2 #0 private, #1 followers, #2 all
      t.string :tags
      t.timestamps
    end
  end

  def self.down
    drop_table :channels
  end
end

