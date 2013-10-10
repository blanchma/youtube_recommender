class FacebookCommentsController < ApplicationController
skip_before_filter :verify_authenticity_token

  def create
      #id corresponde al post
    msg = "#{params[:msg]} via http://MyNew.Tv"
    resp = MiniFB.post(current_user.fb_token, params[:id], :type => "comments",
    :params => {:message => msg } )
    
    render :text => resp.id
  end

  def destroy
    #id corresponde al comment  
    resp = MiniFB.post(current_user.fb_token, params[:id], :type => "",
    :params => {:method => "delete"})
    
    render :text => resp.response
  end

  


end

