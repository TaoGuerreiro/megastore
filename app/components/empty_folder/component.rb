# frozen_string_literal: true

module EmptyFolder
  class Component < ViewComponent::Base
    attr_reader :title, :subtitle

    def initialize(title:, subtitle:)
      @title = title
      @subtitle = subtitle
    end
  end
end
