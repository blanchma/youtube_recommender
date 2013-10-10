class RenamePhraseScoresColumns < ActiveRecord::Migration
  def self.up
   
    add_column :phrase_scores, :p_rare_cache, :float
  end

  def self.down

    remove_column :phrase_scores, :p_rare_cache
  end
end

