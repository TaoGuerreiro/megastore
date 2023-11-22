module ApplicationHelper
  include Filterable::FilterableHelper

  def home?(params)
    params[:controller] == "pages" && params[:action] == "home"
  end
end
