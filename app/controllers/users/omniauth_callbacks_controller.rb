class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  def twitter
  
    omniauth = env["omniauth.auth"]
    
    if user_signed_in? #or User.find_by_email(auth.recursive_find_by_key("email"))
      user = User.find_by_tw_uid omniauth['uid']      

      if user
        flash[:notice] = "Twitter account used"
        render :action => :close, :layout => "popup"
      else
        flash[:notice] = "Twitter account added"
        user.apply_omniauth(omniauth)
        user.save
        render :action => :close, :layout => "popup"
      end
    else
    
      user = User.find_by_tw_uid  omniauth['uid']

      if user
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => omniauth['provider']
        
        sign_in_and_redirect(:user, user)
        #sign_in_and_redirect(authentication.user, :event => :authentication)
      else
          
        #create a new user
        unless omniauth.recursive_find_by_key("email").blank?
          user = User.find_or_initialize_by_email(:email => omniauth.recursive_find_by_key("email"))
        else
          user = User.new
        end

        user.apply_omniauth(omniauth)
        #user.confirm! #unless user.email.blank?

        
        if user.save
          logger.info "User 5 #{user}"  
          flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => omniauth['provider']

          sign_in_and_redirect(:user, user)
        else

                    logger.info user.errors.full_messages
          session[:omniauth] = omniauth.except('extra')
          redirect_to complete_email_path
        end
      end
    end

  end


  def facebook
  
    omniauth = env["omniauth.auth"]
    
    if user_signed_in? #or User.find_by_email(auth.recursive_find_by_key("email"))
      user = User.find_by_fb_uid omniauth['uid']      
      
      if user
        flash[:notice] = "Facebook account used"
        render :action => :close, :layout => "popup"
      else
        flash[:notice] = "Facebook account added"
        user.apply_omniauth(omniauth)
        user.save
        render :action => :close, :layout => "popup"
      end
    else
    
      user = User.find_by_fb_uid  omniauth['uid']
   
      if user
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => omniauth['provider']
        if user.fb_token.nil?
          user.apply_omniauth(omniauth)
          user.save
        end
        sign_in_and_redirect(:user, user)
        #sign_in_and_redirect(authentication.user, :event => :authentication)
      else
          
        #create a new user
        unless omniauth.recursive_find_by_key("email").blank?
          user = User.find_or_initialize_by_email(:email => omniauth.recursive_find_by_key("email"))
        else
          user = User.new
        end
          
        user.apply_omniauth(omniauth)
        #user.confirm! #unless user.email.blank?
        
        if user.save
          flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => omniauth['provider']
          sign_in_and_redirect(:user, user)
        else

          session[:omniauth] = omniauth.except('extra')
          redirect_to complete_email_path
        end
      end
    end

  def failure
    logger.info "FAIL OMNIAUTH"
  end
  
  end

  

  
end
