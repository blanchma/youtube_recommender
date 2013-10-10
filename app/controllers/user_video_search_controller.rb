
class UserVideoSearchController < ApplicationController
  before_filter :authenticate_user!

  skip_before_filter :verify_authenticity_token

  def playlist
    current_user.search_recs_in_facebook
    current_user.clear_screen_list

    #current_user.playlist.reset_index
    FacebookRecommendation.clear_for(current_user)    
    videos = current_user.playlist.peek(3,params[:vid])  
  
    render :json => videos
  end

  def top_video
    logger.info "#{current_user.email} asking for a Topvideo"
   
    top_list = Toplist.new current_user
    id = top_list.recommend
    logger.info "Top video recommended: #{id}"
    @video = top_list.json_for id unless id.nil?
    @video
  end

  def facebook_recommendation
   
    unless REDIS.exists "fb_flag_for_#{current_user.id}" && FacebookRecommendation.empty_for?(current_user)
        logger.info "Checking a Recommendation to #{current_user.email} "
        REDIS.setex "fb_flag_for_#{current_user.id}", 300, true
        @video = FacebookRecommendation.pop_for current_user
        if @video
          logger.info "A #{@video.more.friend_username} in Facebook recommended #{@video.title}"                  
          current_user.suppress_words_in!([@video]) 
        end
    end
    @video
  end

  def user_next_playlist(offset)
    logger.info "#{current_user.email} checking playlist"
    @video = current_user.playlist.next offset
    @video
  end
  
  def user_previous_playlist(offset)
    logger.info "#{current_user.email} checking playlist"   
    @video = current_user.playlist.previous offset
    @video
  end


  def force_random_video
    logger.info "#{current_user.email} getting random video"   
    videos = Video.order("rating_avg,rating_score,views_score, created_at").first(500)
    video_ids = videos.map {|v| v.id}
    
    video_ids = video_ids - current_user.watched_ids - current_user.enqueued_ids - current_user.hated_ids - current_user.screen_list
    unless video_ids.empty?
       @video = Video.find(video_ids.first)
      logger.info "Random video: #{@video.id}"
    end
    @video
  end
  
  def previous_video(ids=params[:ids])
    logger.info "Arg ids= #{ids}"  
    @video = user_previous_playlist params[:id]
    render :json => @video if @video
    render :text => false unless @video
  end


  def next_video(ids=params[:ids])
    logger.info "Arg ids= #{ids}"    

    unless ids.nil?
      ids_as_array = ids.delete("[]").split(",")
      current_user.screen_list=(ids_as_array)
    end
    logger.info "#{current_user.email} screen_list= #{current_user.screen_list}"

    @video = nil

    facebook_recommendation
    if @video
      send_video 
      return
    end

    user_next_playlist params[:id]    
    
    if @video
      send_video 
      return
    end

    top_video
    if @video
      send_video 
      return
    end

    force_random_video
    if @video
      send_video 
      return
    end

        logger.error "VideoSearch FAIL! for #{current_user.email}"
        render :nothing => true unless @video
        return
    
  end

  def send_video    
    if @video.is_a? String 
       @video =   ActiveSupport::JSON.decode @video
         rating = current_user.ratings.not_from_channel.find_by_video_id @video["id"]
         @video["rating"] = rating.action if rating
         @video = ActiveSupport::JSON.encode @video
     else
         rating = current_user.ratings.not_from_channel.find_by_video_id @video.id
         @video.rating = rating.action if rating
      end
     render :json => @video
  end



  private

  def flashMessage msg
    render :update do |page| page << "displayMessage('#{msg}')" end
  end


end

=begin
    videos.collect! do |video|      
            video = ActiveSupport::JSON.decode video
            ratings = current_user.ratings.not_from_channel.find_by_video_id video["id"]
            video["rating"] = ratings.last.action if ratings.size > 0
            ActiveSupport::JSON.encode video       
    end  
 
=end
