Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  require 'shop_domain'

  constraints(ShopDomain) do
    resources :shop
    get '/subscription', to: 'shop#subscription'
    root to: 'pages#home'
  end
end
