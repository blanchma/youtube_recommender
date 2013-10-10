class CreateCommunities < ActiveRecord::Migration
  def self.up
    create_table :communities do |t|
      t.string :name
      t.boolean :public
      t.timestamp :crawled_at, :default => Time.now
      t.timestamps
    end
  end

  def self.down
    drop_table :communities
  end
end
