# frozen_string_literal: true

Rails.application.routes.draw do
  require 'domain'
  devise_for :users
  mount StripeEvent::Engine, at: '/stripe-webhooks'

  post "/webhooks/:source", to: "webhooks#create"

  require 'sidekiq/web'
  authenticate :user, ->(user) { user.queen? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :filterables, only: [], param: :model_name do
    resource :filters, only: %i[show create], controller: 'filterable/filters'
    resources :views, only: %i[create], controller: 'filterable/views'
    collection do
      resources :views, only: %i[destroy], as: :filterable_view, controller: 'filterable/views'
    end
  end



  devise_scope :user do
    namespace :queen do
      authenticate :user, ->(user) { user.queen? } do
        resources :users, only: %i[index show edit update destroy new create] do
          patch :set_localhost, on: :member
        end
        resources :store_orders, only: %i[index show]

      end
    end

    resource :profile, only: %i[edit update]
    namespace :admin do
      authenticate :user, ->(user) { user.queen? || user.admin? } do
        resource :onboarding, only: %i[new create]
        resource :subscription, only: %i[create destroy]
        resources :stores, only: %i[show edit update] do
          resources :categories, only: %i[new create edit update]
          resources :shipping_methods, only: %i[new create edit update]
          resources :specifications, only: %i[new create edit update]
        end
        resources :specifications, only: [:destroy, :index, :new, :create, :edit, :update]
        resources :categories, only: [:destroy, :index, :new, :create, :edit, :update]
        resources :shipping_methods, only: [:destroy]
        resources :collections, only: %i[index new create show edit destroy update]
        resource :bulk_edit_items, only: [] do
          patch :online, on: :member
          patch :offline, on: :member
          patch :add_to_collection, on: :member
        end
        resources :items, only: %i[index new create edit update destroy] do
          delete :remove_photo, on: :member
          patch :archive, on: :member
          patch :unarchive, on: :member
          patch :add_stock, on: :member
          patch :remove_stock, on: :member
        end
        resources :orders, only: %i[index show edit update destroy]

        resource :account, only: %i[show edit update]
      end
    end
  end

  constraints(Domain) do
    root to: 'pages#home'
    get '/contact',       to: 'pages#contact'
    get '/about',         to: 'pages#about'
    post '/send_message', to: 'pages#send_message'
    get '/store',         to: 'stores#show'
    get '/portfolio',     to: 'pages#portfolio'
    resource :checkout, only: [:show] do
      post :confirm_payment, on: :member
    end
    resources :items, only: [:show] do
      resource :checkout, only: [] do
        post :add, on: :member
        post :remove, on: :member
      end
    end
    resources :orders, only: [:show]
    resources :order_intents, only: [:create]
    resource :order_intents, only: [] do
      patch :undo_shipping_method, on: :member
      patch :undo_service_point, on: :member
      patch :shipping_method, on: :member
      patch :service_point, on: :member
    end
  end
end
