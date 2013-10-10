class PhraseScoresAddPhraseId < ActiveRecord::Migration
  def self.up
    add_column :phrase_scores, :phrase_id, :integer
    add_index :phrase_scores, :phrase_id
  end

  def self.down
    remove_index :phrase_scores, :phrase_id
    remove_column :phrase_scores, :phrase_id
  end
end
