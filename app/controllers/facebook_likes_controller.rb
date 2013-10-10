class FacebookLikesController < ApplicationController
  skip_before_filter :verify_authenticity_token

  LIKE_MESSAGE = "I like this via http://MyNew.Tv"

  def create
    resp_likes = MiniFB.post(current_user.fb_token, params[:id ], :type => "likes")
    logger.info "Created Like(#{params[:id]}: #{resp_likes.response})"

    comments = MiniFB.get(current_user.fb_token, params[:id], :type => "comments")
    comment_id = nil
    comments.data.each do |comment|
      if (comment.message.include?(LIKE_MESSAGE) )
        comment_id = comment.id
      end
    end
    
    unless comment_id
      resp_comment_likes = MiniFB.post(current_user.fb_token, params[:id], :type => "comments", :params => {:message => LIKE_MESSAGE } )
      comment_id = resp_comment_likes.id
    end
    
    logger.info "Created comment about Like(#{params[:id]}: #{comment_id})"
    render :text => comment_id
  end

  def destroy
    #id corresponde al post
    resp_likes = MiniFB.post(current_user.fb_token, params[:id], :type => "likes", :params => {:method => "delete"})
    logger.info "Deleted Like(#{params[:id]}: #{resp_likes.response})"
    logger.debug "Going to delete #{params[:comment_id]}"
    if params[:comment_id]
      resp_comment_likes = MiniFB.post(current_user.fb_token, params[:comment_id], :type => "",
      :params => {:method => "delete"})
      logger.info "Deleted comment about Like(#{params[:id]}: #{resp_comment_likes.response})"
    end
    render :text => resp_likes.response
  end


  def show
    resp = MiniFB.get(current_user.fb_token, params[:id], :type => "likes")
    liked = false
    resp.data.each do |like|
      liked = like.id == current_user.fb_uid.to_s
      break if liked
    end
    likes = liked ? resp.data.size - 1 : resp.data.size
    logger.info "Post(#{params[:id]} have #{likes} likes and liked: #{liked}"



    comments = MiniFB.get(current_user.fb_token, params[:id], :type => "comments")
    comment_id = nil
    comments.data.each do |comment|
      if (comment.message.include?(LIKE_MESSAGE) )
        comment_id = comment.id
      end
    end

    render :json => [liked, likes, comment_id]
  end

end

