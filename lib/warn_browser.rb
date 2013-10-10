module WarnBrowser
  def self.included(base)
    base.class_eval do
      helper_method :warn_browser?
    end
  end
  
  Browser = Struct.new(:browser, :version)
  WarnBrowser = [
    Browser.new("Internet Explorer", "9.0")
  ]
  
  def warn_browser?
    return if request.user_agent.blank?
    user_agent = UserAgent.parse(request.user_agent)
    WarnBrowser.detect { |browser| user_agent < browser }
  end
end