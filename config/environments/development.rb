Mynewtv::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  config.log_level = :info
  config.active_support.deprecation = :log

  
  config.action_mailer.default_url_options = { :host => "localhost" }
  

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true
end


FB_API_KEY = "dfa78dcd05d515d4e62bc59052c6b2f3"
FB_SECRET  = "9bcd871e48fbe6b6493a4933b00e144b"
FB_APP_ID  = "126893080668338"
HOST       = "http://localhost:3000/"
RTMP_SERVER = "rtmp://xysqdxcq6.rtmphost.com/videorecorder/_definst_"#"rtmp://localhost/audiorecorder/_definst_"

TW_KEY= "HrE2pIXMbddHRQEt2xmQ"
TW_SECRET = "qCnvEUbmkcePSPB5dadJFwB8mbdVQI7u9tYvkmTW91M"

REDIS =        Redis.new(:db => 1)

ActionMailer::Base.smtp_settings = {
  :tls            => true,
  :address        => "smtp.1and1.com",
  :port           => "587",
  :domain         => "mynew.tv",
  :authentication => :plain,
  :user_name      => "tute@mynew.tv",
  :password       => "heraclito"
}

MiniFB.disable_logging
