Rails.application.routes.draw do
  get 'companies/create'

  get 'companies/authenticate'

  get 'companies/logout'

  get 'companies/oauth_callback'

  resources :vendors

  root to: 'companies#index'

  resources :companies do 
    collection do 
      get :authenticate, defaults: { format: 'json' }
      post :report_ranged, defaults: { format: 'json' }
      get :oauth_callback
      get :logout
      get :xero_create
      get :xero_new

    end
  end

  get '/companies/blue-dot' => 'companies#bluedot'

end
