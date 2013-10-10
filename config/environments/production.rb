Mynewtv::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests

  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => "mynew.tv" }

  # Enable threaded mode
  # config.threadsafe!
end
FERRET_PATH = "/home/mynewtv2/shared/ferret"

FB_API_KEY = "49777456e9cb3764c3b14c943acad964"
FB_SECRET  = "5fe13893b5c7fca39d50c2eae5193d92"
FB_APP_ID  = "111097285601877"
HOST       = "http://mynew.tv/"
RTMP_SERVER = "rtmp://mynew.tv/audiorecorder/_definst_"

TW_KEY= "HrE2pIXMbddHRQEt2xmQ"
TW_SECRET = "qCnvEUbmkcePSPB5dadJFwB8mbdVQI7u9tYvkmTW91M"
TW_CALLBACK = "http://mynew.tv/twitter"

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

Mynewtv::Application.config.middleware.use "ExceptionNotifier",
    :email_prefix => "[MTV] ",
    :sender_address => %{"notifier" <notifier@mynew.tv>},
    :exception_recipients => %w{tute@mynew.tv}
    

