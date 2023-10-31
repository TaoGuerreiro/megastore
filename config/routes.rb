Rails.application.routes.draw do
  get 'items/show'
  require 'domain'
  devise_for :users

  constraints(Domain) do
    root to: 'pages#home'
    get "/contact", to: "pages#contact"
    get "/about", to: "pages#about"
    post '/send_message', to: "pages#send_message"
    get '/store', to: "stores#show"
    resources :items, only: [:show] do
      resource :checkout, only: [] do
        post :add, on: :member
      end
    end
  end

  namespace :admin do
    authenticate :user, -> (user) { user.admin? } do
      resource :store, only: [] do
        get :my_store, on: :member
      end
    end
  end
end
