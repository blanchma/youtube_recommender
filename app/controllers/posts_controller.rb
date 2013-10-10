class PostsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show,:show_by_vid]

  respond_to :json, :js
  respond_to :html, :only => [:show, :new]

  layout 'player'

  def new
    @video = Video.find(params[:video_id])
    @post = current_user.posts.find_by_video_id @video.id
    @post = current_user.posts.new(:video => @video) if @post.nil?

    if request.xhr?
      @post.save if @post.new_record?
      render :text => @post.id
    else
      render 'new', :layout => 'popup'
    end
  end

  def show
    if params[:post_id]
      @post = Post.find_by_id(params[:post_id])
      if @post.nil?
        flash[:notice]="This post doesn't exist"
        return redirect_to root_path unless user_signed_in?
        return redirect_to player_path
      end
      @video = @post.video
      @user = @post.user      
      @video.more={:user_id => @post.user.id, :user_name => @post.user.nickname} if @user
      
    elsif params[:video_id]
      @video = Video.find_by_id(params[:video_id])
      if @video.nil?
        flash[:notice]="This post doesn't exist"
        return redirect_to root_path unless user_signed_in?
        return redirect_to player_path
      end
      if params[:user_id]
        @user = User.find_by_id(params[:user_id])
        @video.more={:user_id => @user.id, :user_name => @user.nickname} if @user
      end
    else
      flash[:notice]="This post doesn't exist"
      return redirect_to root_path unless user_signed_in?
      return redirect_to player_path
    end
=begin
    if @post
      with_cookie = false
      cookies.each do |cookie|
        if cookie[0].match("mtv_post:#{@post.id}")
          logger.info "Cookie already exist for this post(#{cookie[0]}"
          with_cookie  = true
        end
      end

      unless with_cookie
        @post.count+=1
        @post.save
        cookies["mtv_post:#{@post.id}"] = {:value => true, :expires => 2.days.from_now}
        logger.info "Creating a cookie for mtv_post:#{@post.id}"
      end
    end
=end
    @video.from="post"

    if user_signed_in?
      current_user.playlist.prepend(@video) if @video
      return redirect_to player_path
    end

    respond_with(@video) do |format|
      format.any(:js, :json) { render :json => [@video] }
    end
  end


  def create
    post = current_user.posts.new(params[:post])

    if post.save
      Resque.enqueue(PublishPostJob, post.id)

      # respond_with post
      head :ok
    else
      logger.warn "Error saving post #{post.errors.full_messages.to_sentence}"
      head :bad_request
    end
  end


end

