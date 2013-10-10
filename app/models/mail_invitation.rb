class MailInvitation < ActiveRecord::Base
    
    
  belongs_to :from, :class_name => 'User', :foreign_key => 'from'



end

