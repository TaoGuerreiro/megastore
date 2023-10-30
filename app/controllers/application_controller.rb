class ApplicationController < ActionController::Base
  before_action :set_current_store

  def default_url_options
    { host: Current.store.domain || "localhost:3000" }
  end

  private

  def set_current_store
    Current.store = Store.find_by(domain: request.domain)
  end

end
