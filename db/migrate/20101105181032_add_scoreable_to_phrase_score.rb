class AddScoreableToPhraseScore < ActiveRecord::Migration
  def self.up
    rename_column :phrase_scores, :user_id, :scoreable_id
    add_column :phrase_scores, :scoreable_type, :string
    remove_index :phrase_scores, :user_id
    execute "UPDATE phrase_scores SET scoreable_type = 'User'"

  end

  def self.down
    rename_column :phrase_scores, :scoreable_id, :user_id
    remove_column :phrase_scores, :scoreable_type
    add_index :phrase_scores, :user_id
  end
end

