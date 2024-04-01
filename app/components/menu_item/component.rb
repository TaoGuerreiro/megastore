# frozen_string_literal: true

module MenuItem
  class Component < ViewComponent::Base
    def initialize(path:, title:, icon_classes:)
      @path = path
      @title = title
      @icon_classes = icon_classes
    end

    def active?
      request.path == @path
    end

    def active_class
      active? ? "!bg-light !text-contrast translate-x-3 rounded-none rounded-l-lg" : ""
    end
  end
end
