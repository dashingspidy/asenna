Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resources :brands
  resources :products do
    collection do
      get :search
    end
  end
  resources :suppliers
  resources :inventories
  resources :supplier_transactions
  resources :customers do
    member do
      post :create_transaction
    end
  end
  resource :cart, only: [ :show ], controller: :cart do
    post :add
    delete :remove
    post :checkout
    get :search
    patch :update_quantity
    patch :update_cart_discount
    patch :update_payment_method
    post :search_customer
    delete :remove_customer
    patch :update_paying_amount
  end
  get "dashboard", to: "dashboard#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "sessions#new"
  get "dashboard/sales_chart_data", to: "dashboard#sales_chart_data"
end
