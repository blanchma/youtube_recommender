class CreateInvitations < ActiveRecord::Migration
  def self.up
      create_table :mail_invitations do |t|
      t.integer :from  
      t.string  :to
      t.string  :to_email
      t.string  :body
      t.boolean :sended
      t.timestamp :created_at
      t.timestamp :sended_at
    end
      
  end

  def self.down
     drop_table :mail_invitations
  end
end
