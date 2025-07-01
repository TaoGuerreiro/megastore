# frozen_string_literal: true

module ApplicationHelper
  include Filterable::FilterableHelper
  include Pagy::Frontend

  def home?(params)
    params[:controller] == "pages" && params[:action] == "home"
  end

  def status_color_class(status)
    case status
    when "pending"
      "bg-yellow-100 text-yellow-800"
    when "confirmed"
      "bg-green-100 text-green-800"
    when "cancelled"
      "bg-red-100 text-red-800"
    when "completed"
      "bg-blue-100 text-blue-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end
end
