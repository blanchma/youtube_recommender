class SetActivatedAtInAdminUsers < ActiveRecord::Migration
  def self.up
    User.all.each do |user|      
      user.update_attribute :activated_at, Time.now if user.activated_at.nil?
    end

  end

  def self.down
  end
end
