class RemoveSuppressFromPhraseScores < ActiveRecord::Migration
  def self.up
      remove_column :phrase_scores, :update_token
      remove_column :phrase_scores, :suppress_until
  end

  def self.down
      add_column :phrase_scores, :update_token, :integer
      add_column :phrase_scores, :suppress_until, :float
  end
end
