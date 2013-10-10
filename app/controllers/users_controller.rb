class UsersController < ApplicationController
  before_filter :authenticate_user!, :only => [:admin_pw, :adminify, :pending, :edit, :to_activate, :activate]
  before_filter :require_admin, :only => [:to_activate, :activate]
  layout 'homepage'

  def to_activate
    @users = User.pending
  end

  def pending

  end

  def activate
    user = User.find(params[:id])
    user.activate!
    UserMailer.activated(user.id).deliver #unless Rails.env = 'development'
    flash[:notice] = "Activated user #{user.email}"
    redirect_to users_to_activate_path
  end

  def admin_pw
  end

  def adminify
    if params[:password] == 'rubiorubio'
      current_user.admin = true
      current_user.activated_at = Time.now
      current_user.debug = true
      current_user.save!
      flash[:notice] = 'This user is an admin now'
      redirect_to player_path
    else
      flash[:notice] = 'Wrong.'
      render 'admin_pw'
    end
  end



  def toggle_follow
    logger.info "Edit follow condition for user id=#{params[:id]}"
    user = User.find params[:id]
    follow = false
    unless current_user.id == params[:id]
      if current_user.following? params[:id]
        current_user.following.delete(user)
        unfollow = UnfollowEvent.new(:from => current_user, :from_name => current_user.nickname, :to_mtv_id => params[:id])
        unfollow.save
      else
        current_user.following << user
        #      unfollow = FollowEvent.new(:from => current_user, :from_name => current_user.nickname, :to_mtv => params[:id])
        #  unfollow.save
        follow = true
      end
    end

    render :text => follow
  end

  def search
    @users = User.search(params[:query], params[:page])
    #the_user = current_user || User.find(params[:user_id])
 
    user_results = collect_users(@users)      

    search_results = [@users.previous_page, @users.next_page, user_results]

    render :json => search_results
  end


  def followers
    query = params[:query]
    page = params[:page]
    the_user = current_user || User.find(params[:user_id])

    @followers = the_user.search_followers(query, page)

    followers_collected = collect_users(@followers)     
    followers_results = [@followers.previous_page, @followers.next_page, followers_collected]

    render :json => followers_results
  end

  def following
    query = params[:query]
    page = params[:page]
    the_user = current_user || User.find(params[:user_id])

    @following = the_user.search_following(query, page)

    following_collected = collect_users(@following)

    following_results = [@following.previous_page, @following.next_page, following_collected]

    render :json => following_results
  end

  def info
    @user = User.find params[:id]
    if @user    
      @user.follower?(current_user) if user_signed_in?
      
      render :json => @user.to_json(:methods => [:likes, :hates, :is_follower, :count_followers])
    else
      render :json => false
    end
  end


  def publishing_to_tw?
    render :text => current_user.twitter_connected? && current_user.publish_to_tw?
  end

  def flare
    user = User.find params[:id]
    REDIS.hset "flare:#{user.id}", "video", params[:video_id]
    REDIS.hset "flare:#{user.id}", "position", params[:position]
    REDIS.expire "flare:#{user.id}", 120
    render :text => true
  end

  def track
    user = User.find params[:id]
    video_id = REDIS.hget "flare:#{user.id}", "video"
    position = REDIS.hget "flare:#{user.id}", "position"
    render :json => {:video_id => video_id, :position => position }
  end

  private
  def collect_users(users)
    user_results = users.collect do |user|
      next if current_user && user.id == current_user.id
      match = false
      following = false
      if user_signed_in?
        match = !user.custom_nickname.nil? && user.custom_nickname.include?(params[:query]) ? user.custom_nickname : user.email
        following = current_user.following?(user.id)
      end
      [user.id, match, following, user.private_channel, user.channels.count > 0, user.slug, user.flaring?  ]
    end
    user_results
  end


end

