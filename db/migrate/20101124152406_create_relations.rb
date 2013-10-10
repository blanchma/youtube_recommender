class CreateRelations < ActiveRecord::Migration
  def self.up
    create_table :relations, :id => false do |t|

      t.integer :parent_id
      t.integer :child_id
    end
  end

  def self.down
    drop_table :relations
  end
end
