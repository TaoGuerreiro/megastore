module ApplicationHelper
  include Filterable::FilterableHelper
  include Pagy::Frontend

  def home?(params)
    params[:controller] == "pages" && params[:action] == "home"
  end
end
