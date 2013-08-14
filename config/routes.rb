Gallery::Engine.routes.draw do
  namespace :admin do    
    post 'fetch_albums' => "albums#fetch_albums"
    resources :albums do
      post 'public' => "albums#set_public"
      post 'private' => "albums#set_private"
      post 'fetch_photos' => "albums#fetch_photos"
      resources :photos do

      end
    end
    get '' => "admin#index"
  end

  resources :albums do
    resources :photos
  end

  get "auth/:provider/callback" => "omniauth_callbacks#callback"

  get '' => "albums#index", :as => :gallery_root
end
