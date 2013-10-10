class AddDeltaToVideos < ActiveRecord::Migration
  def self.up
        unless column_exists?(:videos, :delta)
            add_column(:videos, :delta, :boolean, :default => true, :null => false)  
      end
  end

  def self.down
    remove_column :videos, :delta
  end
end
