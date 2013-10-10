class UserMailer < ActionMailer::Base
  include Resque::Mailer
  
  default :from => "donotreply@mynew.tv"#, :return_path => 'tute@mynew.tv'
  
  def new_user(user_id)
    @user = User.find user_id    
    to = "<alex@abinventio.com>, <tute@mynew.tv>"
    to = "<tute@mynew.tv>" if Rails.env == 'development'
    mail(:to => to, :subject => "New User!")
  end

  def activated(user_id)
    @user = User.find user_id
    mail(:to => @user.email, :subject => 'Your MyNew.TV account is active!')
  end
  
  def invitation(invitation_id)
     logger.info "Invitation: #{invitation_id}"
     @invitation = MailInvitation.find invitation_id 
     @from = @invitation.from
     mail(:to => "#{@invitation.to} <#{@invitation.to_email}>", :subject => '#{@from.nickname} invite you to try MyNew.Tv')
  end

end

