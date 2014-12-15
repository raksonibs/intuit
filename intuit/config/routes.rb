Rails.application.routes.draw do
  resources :vendors do 
    collection do 
      get :authenticate
      get :oauth_callback
    end
  end

  root to: 'vendors#index'

end
