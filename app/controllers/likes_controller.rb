class LikesController < ApplicationController
  include ApplicationHelper
  
  def show
    rating = Rating.find(params[:id])
    
    if user_signed_in?
      
      if session['redirected_to_facebook']
        session.delete('redirected_to_facebook')
        REDIS.incr "likes:signed_up_from_facebook"
        REDIS.rpush "likes:facebook_signup_users", current_user.id
      end
      
      logger.debug "would prepend to playlist: #{rating.video}"
      current_user.prepend_to_playlist(rating.video)
      redirect_to player_path
    else
      # connect via FB
      logger.info "going to connect via FB"
      logger.info "session: #{session.inspect}"
      
      session['redirected_to_facebook'] = 1
      REDIS.incr "likes:redirected_to_facebook"
      
      session['user_return_to'] = request.request_uri
      logger.debug "NOW session: #{session.inspect}"
      redirect_to oauth2_url
    end
  end
  
  def friends_likes
     count = Rating.count_by_sql "SELECT COUNT(r.id) FROM ratings r, follows f WHERE f.follower_id = #{current_user.id} AND f.followed_id = r.user_id AND r.video_id = #{params[:video_id]}" 
     user_liked = Rating.find_by_sql "SELECT id FROM ratings r WHERE r.video_id = #{params[:video_id]} AND r.user_id = #{current_user.id}"
     render :json => {:user => user_liked, :count => count}
  end
  
end
