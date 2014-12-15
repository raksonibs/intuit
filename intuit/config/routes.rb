Rails.application.routes.draw do
  get 'companies/create'

  get 'companies/authenticate'

  get 'companies/logout'

  get 'companies/oauth_callback'

  resources :vendors

  root to: 'companies#index'

  resources :companies do 
    collection do 
      get :authenticate
      get :oauth_callback
      get :logout
    end
  end

end
