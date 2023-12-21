Rails.application.routes.draw do
  require 'domain'
  devise_for :users
  mount StripeEvent::Engine, at: '/stripe-webhooks'

  require "sidekiq/web"
  authenticate :user, ->(user) { user.queen? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :filterables, only: [], param: :model_name do
    resource :filters, only: %i[show create], controller: "filterable/filters"
    resources :views, only: %i[create], controller: "filterable/views"
    collection do
      resources :views, only: %i[destroy], as: :filterable_view, controller: "filterable/views"
    end
  end

  devise_scope :user do
    resource :profile, only: %i[edit update]
    namespace :admin do
      authenticate :user, -> (user) { user.queen? || user.admin? } do
        resources :stores, only: [:show, :edit, :update] do
          resources :categories, only: [:new, :create, :edit, :update]
          resources :shipping_methods, only: [:new, :create, :edit, :update]
          resources :specifications, only: [:new, :create, :edit, :update]
        end
        resources :specifications, only: [:destroy]
        resources :categories, only: [:destroy]
        resources :shipping_methods, only: [:destroy]
        resource :bulk_edit_items, only: [] do
          patch :online, on: :member
          patch :offline, on: :member
        end
        resources :items, only: [:index, :new, :create, :edit, :update, :destroy] do
          delete :remove_photo, on: :member
          patch :archive, on: :member
          patch :unarchive, on: :member
          patch :add_stock, on: :member
          patch :remove_stock, on: :member
        end
        resources :orders, only: [:index, :show, :edit, :update, :destroy]

        resource :account, only: [:show, :edit, :update]
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
      post :shipping_method, on: :member
      post :comfirm_payment, on: :member
    end
    resources :items, only: [:show] do
      resource :checkout, only: [] do
        post :add, on: :member
        post :remove, on: :member
      end
    end
    resources :orders, only: [:show, :create]
  end
end
