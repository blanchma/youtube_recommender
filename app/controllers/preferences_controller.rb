class PreferencesController < ApplicationController
  before_filter :authenticate_user!

  respond_to :json

  def toggle_publish_fb
    old_status = current_user.publish_to_fb
    new_status = !old_status
    current_user.update_attribute(:publish_to_fb, new_status)
    unless request.xhr?
      respond_with new_status
    else
      render :text => new_status
    end
  end

  def toggle_publish_tw
    if current_user.twitter_connected?
      old_status = current_user.publish_to_tw
      new_status = !old_status
      current_user.update_attribute(:publish_to_tw, new_status)
      render :text => new_status
    else
      render :text => "window.open('/auth/twitter','','width=800,height=500,toolbar=no,location=no,menubar=no,scrollbars=no,resizable=yes');"+
      "setTimeout('Mynewtv.publishAllLikedOnTwitter()',20000);"

    end
  end

  def show
    @user = current_user
    @user.custom_nickname = @user.nickname
    render 'edit'
  end

  def edit
    @user = current_user
    @user.custom_nickname = @user.nickname
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      logger.info "updated, setting flash: #{@user.attributes.inspect}"
      flash[:notice] = "Your preferences have been updated!"
      redirect_to preferences_path
    else
      render 'edit'
    end

  end
end

