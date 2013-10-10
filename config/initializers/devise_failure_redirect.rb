unless defined?(Devise::FailureApp)
  raise "NO FAILURE APP YET I HATE THIS"
end

module Devise
  class FailureApp < ActionController::Metal
    def redirect
      store_location!
      Rails.logger.error "Error in Devise"
      flash[:alert] = i18n_message unless flash[:notice]
      redirect_to send(:"new_#{scope}_registration_path")
    end
  end
end
    
