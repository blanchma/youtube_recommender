class UserChannelsController < ApplicationController

  #  before_filter :check_private_channel
  respond_to :json, :js

  def show
    @user = User.find params[:id]   
    # get 5 most recent uniq video ids...
    # video_ids = @user.ratings.liked.newest.limit(10).collect(&:video_id).uniq.first(6)
    # videos = Video.find(video_ids)
  
    if params[:vid] && @user.ratings.liked.exists?(:video_id => params[:vid])
      last_rating = @user.ratings.find_by_video_id params[:vid]
      videos = @user.ratings.liked.before_with(last_rating.id).limit(20).collect do |rating|
        #v = rating.video
        #v.rating_id = rating.id
        #v
        rating.video_id
      end
    else
      logger.info "Doesn't provide a vid or doesn't exist to start user channels"
      videos = @user.ratings.liked.newest.limit(20).collect do |rating|
        #v = rating.video
        #v.rating_id = rating.id
        #v
        rating.video_id
      end

    end
   
    videos = videos.uniq.first(6)

    json_array = videos.collect  do |id|
      video = Video.find id
      video.as_json
    end
    if videos.size > 0
      render :json => json_array
    else
      render :json => false
    end
  end

  def prev
    user = User.find params[:id]
    last_rating = user.ratings.find_by_video_id params[:video_id]
    previous_ratings = user.ratings.liked.after(last_rating.id).limit(5)
    
    keepers = []

    previous_ratings.each do |prev_rating|
      # make sure we don't have dupes in the list
      if prev_rating.video_id != last_rating.video_id
        keepers << prev_rating
      end
    end

    videos = []

    keepers.each do |rating|
      video = rating.video
      video.rating_id = rating.id
      videos << video.as_json
    end
    
    if videos.size > 0
      render :json => videos.first
    else
      render :json => false
    end

  end

  def next
    user = User.find params[:id]
    last_rating = user.ratings.find_by_video_id params[:video_id]
    next_ratings = user.ratings.liked.before(last_rating.id).limit(5)
    
    keepers = []

    next_ratings.each do |next_rating|
      # make sure we don't have dupes in the list
      if next_rating.video_id != last_rating.video_id
        keepers << next_rating
      end
    end

    videos = []

    keepers.each do |rating|
      video = rating.video
      video.rating_id = rating.id
      videos << video.as_json
    end
   
    if videos.size > 0
      render :json => videos.first
    else
      render :json => false
    end
      
  end

  
  private
  def check_private_channel
    by_id = User.exists?(:id => params[:id])
    by_nickname = User.exists?(:custom_nickname => params[:id])

    unless by_id || by_nickname
      flash[:info] = "That channel doesn't exist!"
      return redirect_to root_path
    end

    user = User.find_by_nickname(params[:id])
    if user.private_channel?
      unless user_signed_in? && user == current_user
        # private channel!
        flash[:info] = "That channel isn't public!"
        return redirect_to root_path
      end
    end
  end

end

