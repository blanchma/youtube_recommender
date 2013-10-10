class CreatePhrases < ActiveRecord::Migration
  def self.up
    create_table :phrases do |t|
      t.integer :user_id
      t.string  :text
      t.integer :likes,          :default => 0
      t.integer :hates,          :default => 0
      t.integer :total,          :default => 0
      t.float   :p_like,         :default => 0.0
      t.integer :suppress_until
      t.float   :p_unseen_cache, :default => 1

      t.timestamps
    end
    add_index :phrases, :user_id
    add_index :phrases, [:user_id, :text], :unique => true
  end

  def self.down
    remove_index :phrases, :column => [:user_id, :text]
    remove_index :phrases, :user_id
    drop_table :phrases
  end
end
