# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Filterable::FilterableRequest
  include Pagy::Backend

  before_action :set_current_store, :clean_checkout_cart

  def default_url_options
    { host: Current.store.domain || 'localhost:3000' }
  end

  rescue_from ActionPolicy::Unauthorized do |exception|
    redirect_to root_path, alert: exception.result.details[:reason]
  end

  private

  def after_sign_in_path_for(_resource)
    Current.store = Store.find_by(domain: request.domain)

    admin_orders_path
  end

  def set_current_store
    Current.store = Store.find_by(domain: request.domain)
  end

  def clean_checkout_cart
    return if current_user

    return unless Item.where(id: session[:checkout_items]).blank?

    session.clear
    session[:checkout_items] = []
  end
end
