class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.integer :user_id
      t.integer :video_id
      t.string  :message
      t.string  :external_id
      t.string  :service
      t.boolean :published, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
