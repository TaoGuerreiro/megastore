class ApplicationController < ActionController::Base
  before_action :set_current_store

  private

  def set_current_store
    Current.store = Store.find_by(domain: request.domain)
  end

end
