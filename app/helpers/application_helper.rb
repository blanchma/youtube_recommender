module ApplicationHelper



  def show_flash
    [:notice, :info, :warning, :message, :error].collect do |key|
      content_tag(:div, flash[key].html_safe, :class => "flash flash_#{key}") if flash[key]
    end.join.html_safe
  end

  def show_browser_warning?
    if warn_browser?
      content_tag(:div, :class => 'browser_warning') do
        "You'll have a better experience with one of " +
        link_to('these browsers', '/browser_warning') +
        "."
      end
    end
  end

  def facebook_auth_url
    MiniFB.oauth_url(FB_APP_ID, HOST + "auth/facebook/callback",
    :scope=>MiniFB.scopes.join(",")) # This asks for all permissions
  end

  def oauth2_url
    session_sign_in_url = Devise::session_sign_in_url(request,::Devise.mappings[:user])
    Devise::oauth2_client.web_server.authorize_url(
    :redirect_uri => session_sign_in_url,
    :scope => Devise::requested_scope
    )
  end



  def fb_connect_button
    content_tag(:a, :href => "/users/auth/facebook", :class => 'fb_button fb_button_large') do
      content_tag(:span, :id => 'fb_login_text', :class => 'fb_button_text') do
        'Connect with Facebook'
      end
    end
  end

  def fb_button_link_to(text, url, opts={})
    content_tag(:a, :href=>url, :class => 'fb_button fb_button_large') do
      content_tag(:span, :class => 'fb_button_text') do
        text
      end
    end
  end

  def fb_connect_button_2
    content_tag(:a, :href => facebook_auth_url, :class => 'fb_button fb_button_large') do
      content_tag(:span, :id => 'fb_login_text', :class => 'fb_button_text') do
        'Connect with Facebook'
      end
    end
  end


end

