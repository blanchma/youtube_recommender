class FacebookInvitationsController < ApplicationController
    skip_before_filter :verify_authenticity_token
   #Facebook Feed can include message, picture, link, name, caption, description, source

  def create
      feed = {:message => params[:msg], :link => "http://mynew.tv", :picture => "http://mynew.tv/images/layout/logo_small_square.png", :name => "Try MyNew.Tv", :description => "MyNew.TV helps you discover & share videos you love" }
    #id corresponde al friend_id  
    resp = MiniFB.post(current_user.fb_token, params[:id], :type => "feed", :params => feed)
    render :text => resp.id
  end

  def destroy
    #id corresponde al feed
    resp = MiniFB.post(current_user.fb_token, params[:id], :type => "", :params => {:method => "delete"})
    render :text => resp.response
  end


end

