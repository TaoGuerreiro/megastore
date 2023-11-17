module ApplicationHelper

  def home?(params)
    params[:controller] == "pages" && params[:action] == "home"
  end
end
