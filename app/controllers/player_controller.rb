class PlayerController < ApplicationController
  #  before_filter :authenticate_user!
  #before_filter :active_user?
#  before_filter :has_phrases?
  before_filter :warn_bad_browser
  before_filter :build_url

  layout 'player'

  def build_url          
    unless params[:user] || params[:channel] || params[:public]
      if user_signed_in? && current_user.activated?
        if current_user.phrase_scores.count < 3
          redirect_to phrases_path          
        else
          params[:user] = current_user.slug
          redirect_to "/play/#{current_user.slug}"          
        end
      else
        params[:public] = true
        redirect_to "/play/public"               
      end
    end
    @playlist = true
  end

  def show
    #@search = RedisSearch.new(current_user, current_user.debug)
    if params[:user]
      begin
            
        @user = User.find params[:user]
          
        if @user.activated?
           @owner = user_signed_in? && current_user.id == @user.id
           if @owner && current_user.phrase_scores.count < 3
            redirect_to phrases_path          
          end          
        else
          flash[:notice]="Channel not avalaible yet"
          params[:public] = true
          redirect_to "/play/public"
        end
      rescue
        if user_signed_in?
          params[:user] = current_user.slug
          redirect_to "/play/#{current_user.slug}"  
        else
          params[:public] = true
          redirect_to "/play/public"  
        end
      end
    end
    
    
    if @user && params[:channel]
      begin
        @channel = Channel.find params[:channel]
        
      rescue
        flash[:notice]="#{params[:channel]} doesn't exist"
        if @user
          redirect_to "/play/#{@user.slug}"          
        else
           params[:public] = true
          redirect_to "/play/public"          
        end
      end       
    end
    
    unless @user
      logger.info "Public channel"
    end
  end

  def search_debug

  end

  def audio_recorder
    #@video = Video.find params[:video_id]
  end


  def debug_toggle
    current_user.debug = !current_user.debug
    current_user.save!
    redirect_to player_path
  end

  private
  def has_phrases?
    if user_signed_in?
          puts "#{current_user.email} has #{current_user.phrase_scores.count} phrases scores"
      unless 
        redirect_to wait_path
      end
    end
  end
end

