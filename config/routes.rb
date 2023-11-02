Rails.application.routes.draw do
  require 'domain'
  devise_for :users
  mount StripeEvent::Engine, at: '/stripe-webhooks'

  devise_scope :user do
    resource :profile, only: %i[edit update]

    namespace :admin do
      authenticate :user, -> (user) { user.admin? } do
        resource :store, only: [] do
          get :my_store, on: :member
        end
      end
    end
  end
  constraints(Domain) do
    root to: 'pages#home'
    get "/contact", to: "pages#contact"
    get "/about", to: "pages#about"
    post '/send_message', to: "pages#send_message"
    get '/store', to: "stores#show"
    resource :checkout, only: [:show] do
      post :payment_method, on: :member
      post :comfirm_payment, on: :member
    end
    resources :items, only: [:show] do
      resource :checkout, only: [] do
        post :add, on: :member
        post :remove, on: :member
      end
    end
    resources :orders, only: [:create, :show]
  end
end
