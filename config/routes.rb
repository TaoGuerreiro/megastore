# frozen_string_literal: true

Rails.application.routes.draw do
  require "domain"
  devise_for :users
  mount StripeEvent::Engine, at: "/stripe-webhooks"
  get "/", to: "pages#home"

  post "/webhooks/:source", to: "webhooks#create"

  require "sidekiq/web"
  authenticate :user, -> (user) { user.queen? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  resources :filterables, only: [], param: :model_name do
    resource :filters, only: %i[show create], controller: "filterable/filters"
    resources :views, only: %i[create], controller: "filterable/views"
    collection do
      resources :views, only: %i[destroy], as: :filterable_view, controller: "filterable/views"
    end
  end

  get "/admin", to: "admin/items#index"

  devise_scope :user do
    namespace :queen do
      authenticate :user, -> (user) { user.queen? } do
        resources :users, only: %i[index show edit update destroy new create] do
          patch :set_localhost, on: :member
        end
        resources :store_orders, only: %i[index show]
        resources :events, only: [:index, :show] do
          post :relaunch, on: :member
        end
      end
    end

    resource :profile, only: %i[edit update]

    namespace :admin do
      authenticate :user, -> (user) { user.queen? || user.admin? } do
        resource :instagram, only: [:show]
        resources :authors do
          delete :remove_avatar, on: :member, controller: :avatars
        end
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
        resources :collections, only: %i[index new create edit destroy update]
        resources :carousel_cards, only: %i[new create edit destroy update] do
          patch :update_position, on: :member
        end
        resource :bulk_edit_items, only: [] do
          patch :online, on: :member
          patch :offline, on: :member
          patch :add_to_collection, on: :member
        end

        resources :items, only: %i[index new create edit update destroy] do
          delete :remove_photo, on: :member, controller: :photos
          patch :archive, on: :member, controller: :archives
          patch :unarchive, on: :member, controller: :archives
          patch :add_stock, on: :member, controller: :stocks
          patch :remove_stock, on: :member, controller: :stocks
        end

        resources :orders, only: %i[index show destroy]
        resources :bookings, only: %i[index new create show edit update destroy] do
          post :add_step, on: :member
          post :reset_steps, on: :member
        end
        resources :venues
        resources :booking_contacts
        resource :account, only: %i[show edit update]
      end
    end
  end

  constraints(Domain) do
    root to: "pages#home"
    get "/contact",         to: "pages#contact"
    get "/about",           to: "pages#about"
    post "/send_message",   to: "pages#send_message"
    get "/store",           to: "stores#show"
    get "/library",         to: "stores#library"
    get "/portfolio",       to: "pages#portfolio"
    get "/authors", to: "ttt/authors#index"
    get "/authors/:id", to: "ttt/authors#show", as: :author
    get "/confidentiality", to: "pages#confidentiality"

    resource :checkout, only: [:show] do
      post :confirm_payment, ons: :member
    end
    resources :items, only: [:show] do
      resource :checkout, only: [] do
        post :add, on: :member, controller: :carts
        post :remove, on: :member, controller: :carts
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
