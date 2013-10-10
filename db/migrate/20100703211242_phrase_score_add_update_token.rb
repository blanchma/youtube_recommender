class PhraseScoreAddUpdateToken < ActiveRecord::Migration
  def self.up
    add_column :phrase_scores, :update_token, :integer
    add_index :phrase_scores, [:user_id, :update_token], :name => "update_token_index"
  end

  def self.down
    remove_index :phrase_scores, :name => :update_token_index
    remove_column :phrase_scores, :update_token
  end
end
