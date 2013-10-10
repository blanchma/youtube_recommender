class RatingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_admin, :only => :history
  layout 'debug'
  respond_to :json

  skip_before_filter :verify_authenticity_token, :only => [:create]

  def create      
    
    if params[:rating][:channel_id]
      ratings = current_user.ratings.where({:video_id => params[:rating][:video_id], 
      :channel_id => params[:rating][:channel_id]})
    elsif params[:rating][:user_channel_id]
     ratings = current_user.ratings.where({:video_id => params[:rating][:video_id], 
     :user_channel_id => params[:rating][:user_channel_id]})
    else
       ratings = current_user.ratings.where({:video_id => params[:rating][:video_id]})
    end
    rating = ratings.last
    

    if rating 
      rating.update_attributes(params[:rating])
   else
      rating = current_user.ratings.new(params[:rating])
    end
    
    if  rating.save
      if rating.liked? && (rating.user.publish_to_fb? || rating.user.publish_to_tw?)
        # make a Post for this rating
        logger.info "Creating FB Post for #{rating.video.id}..."
        rating.user.posts.create(:video => rating.video)
      end
      respond_with rating
    else
      logger.warn "Error saving rating for #{rating.video_id}: #{rating.errors.full_messages.to_sentence}"
      head :bad_request
    end
    # else
    #     render :text => "Already exists a rating for #{params[:rating]}"
    # end
  end

  def history
    @dates = (0..14).collect {|i| Date.today - i}

    @data = {}
    @dates.each do |date|
      @data[date.to_s(:db)] = {
        :likes   => Rating.liked.on_date(date).count,
        :hates   => Rating.hated.on_date(date).count,
        :watched => Rating.watched.on_date(date).count,
        :total => Rating.on_date(date).count,
        :percent_liked     => Rating.percent_liked(date),
        :avg_percent_liked => Rating.average_percent_liked(date-6.days, date)
      }
    end

    #SELECT * FROM users u ORDER BY LAST_SIGN_IN_AT DESC LIMIT 5
    @user_dates = (0..10).collect {|i| Date.today - i}
    @users = User.active.order("last_sign_in_at DESC").where("last_sign_in_at IS NOT NULL").limit(10)
    @users_data = {}
    @users.each do |user|
      @user_dates.each do |date|          
        
        @users_data["#{user.id}:#{date.to_s(:db)}"] = {
          :likes   => user.ratings.liked.on_date(date).count,
          :hates   => user.ratings.hated.on_date(date).count,
          :watched => user.ratings.watched.on_date(date).count,
          :total => user.ratings.on_date(date).count,
          :percent_liked     => user.ratings.percent_liked(date),
          :avg_percent_liked => user.ratings.average_percent_liked(date-6.days, date)          
        }
      end
    end

  end
  
  def destroy
    if user_signed_in? && params[:video_id] 
      ratings = current_user.ratings.where("video_id = ? and action = ?", params[:video_id], params[:rating][:action])            
      if ratings.size > 0
        ratings.each do |rating|
          logger.info "Destroy #{params[:rating][:action]} for vid: #{ params[:video_id] }"
          video = rating.video          
          rating.destroy
          video.rating_from current_user          
          current_user.playlist.replace_video(video)          
        end
        render :json => true
      else
        logger.info "Not found: #{params[:rating][:action]} for vid: #{ params[:video_id] }"
        render :json => false
      end
      
    else
      logger.info "User not found"
      render :json => false
    end
  end


end

