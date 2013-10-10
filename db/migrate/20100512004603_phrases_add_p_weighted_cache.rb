class PhrasesAddPWeightedCache < ActiveRecord::Migration
  def self.up
    remove_column :phrases, :p_unseen_cache
    
    add_column :phrases, :p_weighted_cache, :float, :default => 0.0
    add_index :phrases, :p_weighted_cache
    Phrase.reset_column_information
    Phrase.all.each {|p| p.save!}
  end

  def self.down
    add_column :phrases, :p_unseen_cache, :float, :default => 1.0
    
    remove_index :phrases, :p_weighted_cache
    remove_column :phrases, :p_weighted_cache
  end
end
