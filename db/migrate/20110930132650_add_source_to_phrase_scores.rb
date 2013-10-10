class AddSourceToPhraseScores < ActiveRecord::Migration
  def self.up
    add_column :phrase_scores, :source, :string
  end

  def self.down
    remove_column :phrase_scores, :source
  end
end
