class ChannelsController < ApplicationController
  layout 'channels'
  
  before_filter :find_user
  before_filter :authenticate_user!, :only => [:add, :remove]

  respond_to :json, :js


  def show
    @channel = Channel.find params[:id]
    videos = @channel.playlist.peek 5
    render :json => videos
  end

  def prev
    channel = Channel.find params[:id]
    video = channel.playlist.previous params[:video_id]

    if video
      render :json => video
    else
      logger.info "No more videos after #{params[:video_id]}."
      render :text => false
    end

  end

  def next        
    channel = Channel.find params[:id]
    video = channel.playlist.next params[:video_id]

    if video
      render :json => video
    else
      logger.info "No more videos before #{params[:video_id]}."
      render :text => false
    end
  end

  def unset
    channel = Channel.find params[:id]
    if channel.videos.exists? params[:video_id]
      video = Video.find(params[:video_id])
      channel.videos.delete video
    end
    render :json => channel.playlist.remove(params[:video_id])
  end

  def index
    if params[:category]
      @channels = Channel.where(:category => params[:category]).paginate(:page => params[:page], :per_page => 30)
    else      
      @channels = Channel.paginate(:page => params[:page], :per_page => 30)
    end
  end

  def create
    @channel = Channel.create(:creator => current_user, :name => params[:name])
    
     params[:video_ids].split(",").each do |id|
           seed =  Video.find_by_id id
            @channel.videos << seed if seed
      end
      
    if @channel.save
      message = "Successfuly created channel: #{@channel.name}. <br/>Share it with: #{@channel.link}"
      logger.info message
      render :update do |page|
          
        page << "setChannelMessage('#{message}', false)"
        page.insert_html(:top, 'channels_displayer', :partial => "channels/item", :locals => {:channel => @channel})
        page << "channel_modal.close()"
        page << "setDroppableChannel('channel_item_#{@channel.id}')"
      end
    else
      message = @channel.errors.full_messages.join("<br/>")#.gsub!(/'/, "\\\\'")#gsub!(/[']/, '\\\\\'')
        message = message.gsub(/'/, "\\\\'")
      logger.info message

      render :update do |page|
          
        page << "setChannelMessage('#{message}', true)"
      end
    end
  end


  def destroy
    @channel = @user.channels.find params[:id]
    @channel.destroy
    render :update do |page|
      page << "setChannelMessage('Channel successfully deleted', false)"
      page.remove "channel_item_#{@channel.id}"
    end

  end

  def add
    channel = @user.channels.find params[:id]
    if channel.add_seed params[:vid]      
      render :update do |page|
        page << "setChannelMessage('Sucessfully added.',false) "
      end

    else
      render :update do |page|
        page << "setChannelMessage('Already added.',false) "
      end      
    end

  end

  def remove
    channel = @user.channels.find params[:id]
     
    if channel.videos.remove_seed params[:vid]
      render :update do |page|
        page << "setChannelMessage('Sucessfully removed.',false) "
      end
    else 
      render :update do |page|
        page << "setChannelMessage('Already removed.',false) "
      end           
    end
  end

  def info
    @channel = Channel.find params[:id]
    if @channel    
      @channel.follower?(current_user) if user_signed_in?      
      render :json => @channel.to_json(:methods => [:likes, :hates, :is_follower, :count_followers])
    else
      render :json => false
    end
  end

  def unfollow
    @channel = Channel.find params[:id]
    if user_signed_in?    
      @channel.followers.delete current_user
      render :json => true
    else
      render :json => false
    end
  end

  def follow
    @channel = Channel.find params[:id]
    if user_signed_in?    
      @channel.followers << current_user    
      render :json => true
    else
      render :json => false
    end
    
  end


  private
  def find_user
    @user= User.find params[:user_id]       if params[:user_id]
  end

end

=begin

  def show
    @channel = Channel.find params[:id]
    videos = @channel.videos_ordered.first(3)

    json_array = videos.reverse.collect do |vid|
      vid.as_json
    end

    render :json => json_array
  end

  def prev
    channel = Channel.find params[:id]
    channeled = channel.channeled_videos.select("id").where("video_id = ?", params[:video_id]).first

    channeled_video = channel.channeled_videos(:include =>[:video]).select("id, video_id").where(["video_id != ? AND id < ?",  params[:video_id], channeled.id ]).first if channeled

    if channeled_video
      logger.info "Next video: #{channeled_video.video.title} - #{channeled_video.video.id}"
      render :json => [channeled_video.video]
    else
      logger.info "No more videos after #{params[:video_id]}."
      render :text => false
    end

  end

  def next
    channel = Channel.find params[:id]
    channeled = channel.channeled_videos.select("id").where("video_id = ?", params[:video_id]).first

    channeled_video = channel.channeled_videos(:include =>[:video]).select("id, video_id").where(["video_id != ? AND id > ?",  params[:video_id], channeled.id ]).first if channeled

    if channeled_video
      logger.info "Next video: #{channeled_video.video.title} - #{channeled_video.video.id}"  
      render :json => [channeled_video.video]
    else
      logger.info "No more videos before #{params[:video_id]}."
      render :text => false
    end
  end
=end

