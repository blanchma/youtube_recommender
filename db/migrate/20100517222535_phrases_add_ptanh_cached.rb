class PhrasesAddPtanhCached < ActiveRecord::Migration
  def self.up
    add_column :phrases, :p_tanh_cache, :float, :default => 0.0
    add_index :phrases, :p_tanh_cache
  end

  def self.down
    remove_index :phrases, :p_tanh_cache
    remove_column :phrases, :p_tanh_cache
  end
end
