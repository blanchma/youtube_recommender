class AudioCommentsController < ApplicationController
  respond_to :json, :js

  def index
    @audio_comments = AudioComment.where({ :video_id => params[:video_id] })
    #@audio_comments = AudioComment.first 5
    
    @audio_comments.each do |ac|
       ac.action_from(current_user.id) 
    end
    
    render :json =>  @audio_comments
  end



  def create
    #  debugger
    ac = AudioComment.find_by_location params[:audio_comment][:location]
    # debugger
    if ac
      ac.video_id = params[:audio_comment][:video_id]
      ac.title =  params[:audio_comment][:title]
      ac.public =  params[:public][:all]
      ac.description = params[:audio_comment][:description]
      logger.info "Saving audio comment= #{ac.save}"
      render :update do |page|
        page['form_audio_comment_message'].show
        page.replace_html 'form_audio_comment_message', "Audio comment created!"
        page << "toggleRecorder()"
        #page << "alert(#{ac.to_json})"
        #page << %Q!addAudioComment('#{ac.to_json}')!
        page << "waitForAddAudioComment('#{ac.to_json}')"
        page << "clearCreateAudioForm()"
      end
    else
      render :update do |page|
        page['form_audio_comment_message'].show
        page.replace_html 'form_audio_comment_message', "Complete title and record"
      end
    end

  end

  def destroy
    @ac = AudioComment.find params[:id]
    @ac.video_id = nil
    render :text => @ac.save
  end

  def like
    @ar = AudioRating.find_or_create_by_user_id_and_audio_comment_id current_user.id, params[:audio_id]
    unless @ar.liked?
      @ar.action = 'liked'
      @ar.audio_comment.likes += 1
      @ar.audio_comment.hates -= 1       unless @ar.new_record?

      @ar.save
      @ar.audio_comment.save
    end
    render :json => @ar.audio_comment
  end

  def hate
    @ar = AudioRating.find_or_create_by_user_id_and_audio_comment_id current_user.id, params[:audio_id]

    unless @ar.hated?
      @ar.action = 'hated'
      @ar.audio_comment.hates += 1
      @ar.audio_comment.likes -= 1       unless @ar.new_record?

      @ar.save
      @ar.audio_comment.save
    end
    render :json => @ar.audio_comment
  end

  def listened
    @ac = AudioComment.find params[:audio_id]
    @ac.count_listen += 1
    render :json => @ar.audio_comment
  end

  def destroy_rating
    @ar = AudioRating.find_by_user_id_and_audio_comment_id current_user.id, params[:id]
    if @ar
      @ar.audio_comment.likes -= 1 if @ar.liked?
      @ar.audio_comment.hates -= 1 if @ar.hated?
      @ar.audio_comment.save
      @ar.save
      render :text => @ar.audio_comment
    else
      render :nothing => true
    end


  end

end

