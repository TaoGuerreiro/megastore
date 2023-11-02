class ApplicationController < ActionController::Base
  before_action :set_current_store, :clean_checkout_cart

  def default_url_options
    { host: Current.store.domain || "localhost:3000" }
  end

  private

  def set_current_store
    Current.store = Store.find_by(domain: request.domain)
  end

  def clean_checkout_cart
    if Item.where(id: session[:checkout_items]).blank?
      session.clear
      session[:checkout_items] = []
    end
  end
end
