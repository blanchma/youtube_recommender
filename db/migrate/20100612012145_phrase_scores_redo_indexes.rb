class PhraseScoresRedoIndexes < ActiveRecord::Migration
  def self.up
    remove_index :phrase_scores, :name => :index_phrases_on_p_tanh_cache
    remove_index :phrase_scores, :name => :index_phrases_on_p_weighted_cache
    remove_index :phrase_scores, :name => :index_phrases_on_suppress_until
    remove_index :phrase_scores, :name => :index_phrases_on_user_id_and_text
    remove_index :phrase_scores, :name => :index_phrases_on_user_id
    
    add_index :phrase_scores, :user_id
    add_index :phrases,       :videos_count
    add_index :phrases,       :text
  end

  def self.down
  end
end
