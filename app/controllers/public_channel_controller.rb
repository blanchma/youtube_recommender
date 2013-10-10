class PublicChannelController < ApplicationController


  respond_to :json, :js


  def show
    num = 0
    skip= session[:skip] || 0
    
    videos = Video.order("rating_score DESC, views_score DESC, created_at DESC").offset(skip).limit 5

    json_array = videos.collect do |vid|   
      vid.as_json      
    end
    
    render :json => json_array

  end

  def prev

    skip= session[:skip] || 0
    video = nil
    
    until video do
      ids = Video.select("id").order("rating_score DESC, views_score DESC, created_at DESC").offset(skip).limit(500).collect {|v| v.id }
      index_of_last = ids.index params[:video_id].to_i
  
      if index_of_last  && index_of_last >= 1
        id_of_next = ids[index_of_last - 1]
        video = Video.find id_of_next
        session[:skip]= skip + index_of_last
      else
        skip -=500        
        break if skip == -500
        skip = 0 if skip < 0 
      end
    end

    if video
      logger.info "Next video: #{video.title} - #{video.id}"
      render :json => [video]
    else
      logger.info "No more videos after #{params[:video_id]}."
      render :text => false
    end

  end

  def next
      
    skip= session[:skip] || 0
    video = nil
    until video do
      ids = Video.select("id").order("rating_score DESC, views_score DESC, created_at DESC").offset(skip).limit(500).collect {|v| v.id }
      
      index_of_last = ids.index params[:video_id].to_i
      
      if index_of_last && index_of_last < 499
        id_of_next = ids[index_of_last + 1]
        video = Video.find id_of_next
        session[:skip]= skip + index_of_last      
      else
        skip +=500
      end
    end
    
    if video
      logger.info "Next video: #{video.title} - #{video.id}"
      render :json => [video]
    else
      logger.info "No more videos before #{params[:video_id]}."
      render :text => false
    end
  end



  def index

  end



end

