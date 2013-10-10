class LandingController < ApplicationController
    
    
  def browser_warning

  end

  def homepage
 

    render 'homepage', :layout => 'homepage'
  end
  
end

