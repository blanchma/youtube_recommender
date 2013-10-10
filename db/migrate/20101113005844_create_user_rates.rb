class CreateUserRates < ActiveRecord::Migration
  def self.up
    create_table :user_rates do |t|
      t.integer     :user_id
      t.integer     :likes, :default => 0
      t.float       :avg_liked, :default => 0
      t.integer     :hates, :default => 0
      t.float       :avg_hated, :default => 0
      t.integer     :views, :default => 0
      t.float       :avg_watched, :default => 0
      t.integer     :skips, :default => 0
      t.float       :avg_skipped, :default => 0
      t.timestamps
    end
    User.all.each do |u| 
          u.build_rates
          u.save
      end
  end

  def self.down
          drop_table :user_rates
  end
end

