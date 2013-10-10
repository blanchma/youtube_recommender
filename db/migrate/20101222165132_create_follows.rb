class CreateFollows < ActiveRecord::Migration
  def self.up
       create_table :follows, :id => false do |t|

      t.integer :followed_id
      t.integer :follower_id
    end
  end

  def self.down
          drop_table :follows
  end
end

