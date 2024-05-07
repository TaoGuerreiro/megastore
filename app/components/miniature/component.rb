# frozen_string_literal: true

module Miniature
  class Component < ViewComponent::Base
    attr_accessor :item

    def initialize(item:)
      super
      @item = item
    end
  end
end
