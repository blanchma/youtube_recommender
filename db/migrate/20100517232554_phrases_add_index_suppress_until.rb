class PhrasesAddIndexSuppressUntil < ActiveRecord::Migration
  def self.up
    add_index :phrases, :suppress_until
    
    add_column :phrases, :weight, :float, :default => 0.0
  end

  def self.down
    remove_column :phrases, :weight
    remove_index :phrases, :suppress_until
  end
end
