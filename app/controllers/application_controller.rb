require 'warn_browser'
class ApplicationController < ActionController::Base
  protect_from_forgery :except => [:save_audio_to_db]
  layout 'application'

  before_filter :log_user

  #skip_before_filter :verify_authenticity_token, :only => [:save_audio_to_db]

  include WarnBrowser

  def log_user
    logger.info "[User: #{current_user.email}]" if current_user
  end

  def after_sign_in_path_for(resource_or_scope)
    if resource_or_scope.is_a?(User)
      logger.info "redirecting to player"
      "/play/#{current_user.slug}"
    elsif request.path =~ /\/users\/sign_in/
      logger.warn "redirecting user to player (#{current_user.email})"
      "/play/#{current_user.slug}"
    else
      super
    end
  end

  def avc_settings

    config = {};

    config['connectionstring']=RTMP_SERVER;
    config['codec']=1;
    config['soundRate']=10;
    config['maxRecordingTime']=120;
    config['userId']=(current_user ? current_user.id : '')
    config_string = "donot=removethis"
    config.each do |key, value|
      config_string += "&#{key}=#{value}"
    end

    logger.info "config_string=#{config_string}"

    render :text => config_string
  end

  def save_audio_to_db
    ac = AudioComment.create(:location => params[:streamName], :size => params[:streamDuration], :user_id => current_user.id)  
    logger.info "#{ac.to_s}"
    render :text => "saving to db"
  end

  private
  def warn_bad_browser
    if warn_browser?
      redirect_to '/browser_warning'
    end
  end

  def require_admin
    unless current_user.admin?
      redirect_to '/404.html'
    end
  end

  def active_user?
    logger.info "Active User?"    
    if user_signed_in? && !current_user.activated?
      "Logger not activated"
      flash[:notice]="Your account is pending!"
      params[:pending]=true
    end
  end
  
end

#RubyProfHelper.run("output_file_name.html") do
#  code_to_profile(here)
#end

