class MailInvitationsController < ApplicationController

  def create
      
    @invitation = MailInvitation.new()
    @invitation.from = current_user
    @invitation.to_email = params[:email]
    @invitation.to = params[:friend_name]
    if @invitation.save
           logger.info "Invitation saved. Id=#{@invitation.id}"
           UserMailer.invitation(@invitation.id).deliver
    end
    render :text => true
  end

end

