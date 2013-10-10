class SnoopsController < ApplicationController
  layout 'player'

  def show
      begin
      @user = User.find params[:id]
      rescue
        redirect_to player_path  
        return
      end

      if user_signed_in? && @user.id == current_user.id
        redirect_to player_path  
      end

      @owner = false

      REDIS.sadd "snoop:{@user.id}:users", current_user.id if user_signed_in?
      REDIS.sadd "snoop:{@user.id}:sessions", session[:session_id] unless user_signed_in?       

      REDIS.expire("snoop:{@user.id}:users", 60) if REDIS.ttl("snoop:{@user.id}:users").to_i < 30      
      REDIS.expire("snoop:{@user.id}:sessions", 60) if REDIS.ttl("snoop:{@user.id}:sessions").to_i < 30      
  end

  def flare
    user = User.find params[:id]
    REDIS.setex "flare:#{user.id}:video", 60, params[:video_id]
    REDIS.setex "flare:#{user.id}:position", 60, params[:position]
    render :text => true
  end

  def retrieve
    @user = User.find params[:id]
    video_id = REDIS.get "flare:#{@user.id}:video"
    position = REDIS.get "flare:#{@user.id}:position"
    if video_id
      REDIS.sadd "snoop:{@user.id}:users", current_user.id if user_signed_in?
      REDIS.sadd "snoop:{@user.id}:sessions", session[:session_id] unless user_signed_in?       

      REDIS.expire("snoop:{@user.id}:users", 60) if REDIS.ttl("snoop:{@user.id}:users").to_i < 1      
      REDIS.expire("snoop:{@user.id}:sessions", 60) if REDIS.ttl("snoop:{@user.id}:sessions").to_i < 1  
      video = Video.find video_id    
      render :json => [video, position]
   else
       render :json => false
    end
  end

  def get_visibility
    visibility = REDIS.get "flare:#{user.id}:visibility"
    if visibility
          render :json => visiblity
    else
      render :json => false
    end
      
  end

  def set_visibility
    visibility = REDIS.setex "flare:#{user.id}:visibility", 60
  end 


end
