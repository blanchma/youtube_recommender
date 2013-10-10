class AddSlugsToModels < ActiveRecord::Migration
  def self.up
    add_column :users, :slug, :string
    add_index :users, :slug, :unique => true

    add_column :channels, :slug, :string
    add_index :channels, :slug, :unique => true

    add_column :videos, :slug, :string
    add_index :videos, :slug, :unique => true

    
    User.all.map(&:save)
    Channel.all.map(&:save)
    #Video.all.map(&:save)
  end

  def self.down
  end
end
