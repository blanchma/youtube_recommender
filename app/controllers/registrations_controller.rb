class RegistrationsController < Devise::RegistrationsController

  def complete_email
    build_resource    
  end  

  def update_email
     @user = User.new params[:user]
     @user.apply_omniauth(session[:omniauth]) 
     if @user.save
               session[:omniauth] = nil
                sign_in_and_redirect(:user, @user) 
      else
        logger.info @user.errors.full_messages  
        render :complete_email
      end
  end

  private
  
  def build_resource(*args)
    super
    logger.info "building resource"
    if session[:omniauth]
      @user.apply_omniauth(session[:omniauth])
    end
  end


end
