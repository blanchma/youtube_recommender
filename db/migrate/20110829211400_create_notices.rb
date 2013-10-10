class CreateNotices < ActiveRecord::Migration
  def self.up
    create_table :notices do |t|
      t.integer :priority
      t.string  :message
      t.string  :url
      t.timestamps
    end
  end

  def self.down
    drop_table :notices
  end
end
