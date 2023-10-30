# frozen_string_literal: true
module Notifications
  class Component < ViewComponent::Base
    def initialize(type:, data:)
      super
      @type = type
      @data = prepare_data(data)
      @icon_class = icon_class
      @icon_color_class = icon_color_class

      @data[:timeout] ||= 5
    end

    private

    def icon_class
      case @type
      when "success"
        "fa-check-square"
      when "error" || "alert"
        "fa-exclamation-square"
      else
        "fa-info-square"
      end
    end

    def icon_color_class
      case @type
      when "success"
        "text-green-400"
      when "error"
        "text-red-800"
      when "alert"
        "text-red-400"
      else
        "text-content"
      end
    end

    def prepare_data(data)
      case data
      when Hash
        data
      else
        { title: data }
      end
    end
  end
end
