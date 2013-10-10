class CreateFollowChannels < ActiveRecord::Migration
  def self.up
    create_table :follow_channels do |t|
      t.integer :user_id
      t.string  :channel_id
      t.timestamps
    end
  end

  def self.down
    drop_table :follow_channels
  end
end
