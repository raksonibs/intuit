Rails.application.routes.draw do
  resources :vendors do 
    collection do 
      get :authenticate
      get :oauth_callback
    end
  end

  get 'logout', to: 'vendors#logout', as: :logout

  root to: 'vendors#index'

end
