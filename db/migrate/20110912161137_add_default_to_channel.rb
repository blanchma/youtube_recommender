class AddDefaultToChannel < ActiveRecord::Migration
  def self.up
   
    change_column_default :channels, :visits, 0
    change_column_default :channels, :score, 0
    
    Channel.all.each do |channel|
     
      channel.visits = 0 unless  channel.visits
      channel.score = 0 unless  channel.score
      channel.save if channel.changed?
    end
      
  end

  def self.down
  end
end
