# frozen_string_literal: true

module List
  class Component < ViewComponent::Base
    attr_accessor :links, :item

    def initialize(item:, links:)
      super
      @item = item
      @links = links
    end
  end
end
