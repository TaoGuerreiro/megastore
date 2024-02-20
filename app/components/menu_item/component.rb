# frozen_string_literal: true

module MenuItem
  class Component < ViewComponent::Base
    def initialize(path:, title:, icon_classes:)
      @path = path
      @title = title
      @icon_classes = icon_classes
    end
  end
end
