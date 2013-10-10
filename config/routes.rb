Mynewtv::Application.routes.draw do |map|

  match "/snoop/:id", :to => "snoops#show"
  get "/snoops/:id/retrieve", :to => "snoops#retrieve"
  post "/snoops/:id/flare", :to => "snoops#flare"

 match "/avc_settings", :to  => 'application#avc_settings'
 match "/flvar/avc_settings" , :to  => 'application#avc_settings'

 match "/save_audio_to_db", :to  => 'application#save_audio_to_db'
 match "/flvar/save_audio_to_db" , :to  => 'application#save_audio_to_db'

 root :to => 'welcomes#redirect'

 match '/home', :to => "landing#homepage", :as => "home"

 resources :communities
 resources :phrase_scores
 resources :mail_invitations
 resources :facebook_comments
 resources :facebook_invitations
 resources :facebook_likes

 resources :videos do
  collection do
   get 'search', :to => "videos#search"
   get :audio_comments
  end
  post :favorite
  post :bookmark
 end

 get 'watch/:id', :to => "videos#watch"
 post 'videos/pop/:id', :to => "videos#pop"

 resources :events do
  get :likes, :on => :collection
 end

 resources :audio_comments do
  post :like
  post :hate
  post :listened
  post "destroy/:id" => "audio_comments#destroy"
  post "destroy_rating/:id" => "audio_comments#destroy_rating"
 end

 get "search_debug", :to  => 'debug#search_debug',    :as => 'search_debug'
 get "admin_debug", :to   => 'debug#show',        :as => 'admin_debug'

 get "adminify", :to => 'users#admin_pw'
 put 'adminify', :to => 'users#adminify', :as => 'adminify_user'



 match "/play/public", :to => 'player#show', :public => true, :as => "public"
 match "/play/:user/:channel", :to => 'player#show'
 match "/play/:user", :to => 'player#show'
 match "/play", :to => 'player#show', :as => 'player'
 match "player/debug_toggle", :to  => 'player#debug_toggle'

 get "next_video/:id", :to => 'user_video_search#next_video', :as => 'next_video'
 get "prev_video/:id", :to => 'user_video_search#previous_video', :as => 'prev_video'
 get "top_video", :to => 'user_video_search#top_video'


 get "/invite", :to => 'invitations#new'
 get "/user_playlist", :to => 'user_video_search#playlist', :as => 'user_video_playlist'
 get "em/:user_id", :to => 'embeds#domain'
 get "/browser_warning", :to => 'landing#browser_warning'
 match 'user/publish_fb', :to => "preferences#toggle_publish_fb", :via => :post
 match 'user/publish_tw', :to => "preferences#toggle_publish_tw", :via => :post
 match 'user/publishing_to_tw', :to => "users#publishing_to_tw?", :via => :get
 match 'users/to_activate', :to => "users#to_activate"
 match "/users/:id/activate", :to => 'users#activate', :as => 'activate_user', :via => :put
 match "/users/pending", :to => 'users#pending', :as => 'pending_user'


 devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :registrations => "registrations"} do
  get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'
  get 'users/complete/email', :to => 'registrations#complete_email', :as => "complete_email"
  post 'users/complete/email', :to => 'registrations#update_email', :as => "update_email"
end



 resources :users do
   member do 
     get :info     
  end
  resources :favourites
  resources :bookmarks

  resources :channels do
   member do
    post :add
    delete :remove    
   end
  end
  
  collection do
   get :search
   get :followers
   get :following
  end

  member do
   post :toggle_follow
  end
 end



 resources :channels do
  member do
    get :info
    post :follow
    post :unfollow
   end
 end
 get 'channels/:id/next/:video_id', :to => 'channels#next'
 get 'channels/:id/prev/:video_id', :to => 'channels#prev'
 post 'channels/:id/unset/:video_id', :to => 'channels#unset'

 resources :user_channels, :only => [:show]
 get 'user_channels/:id/next/:video_id', :to => 'user_channels#next'
 get 'user_channels/:id/prev/:video_id', :to => 'user_channels#prev'


 get '/public' => 'public_channel#show', :as => "public_channel"
 get '/public/prev/:video_id', :to => 'public_channel#prev'
 get '/public/next/:video_id', :to => 'public_channel#next'

  

 resource :preferences do
  put :toggle_publishing
 end


 resources :welcomes do
  post :create
 end


 resources :ratings do
  collection do
   get :history
  end
 end
 match "/ratings/:video_id/destroy", :to => "ratings#destroy"


 get "complete/phrases", :to   => 'welcomes#fill_phrases',    :as => 'phrases'
 get "wait/facebook", :to   => 'welcomes#wait_while_facebook',    :as => 'wait_facebook'
 get "/crawl_facebook", :to => 'welcomes#crawl_facebook'




 match '/:controller(/:action(/:id))'
end

