# frozen_string_literal: true

module Miniature
  class Component < ViewComponent::Base
    attr_accessor :item, :method

    def initialize(item:, method: :photos)
      super
      @item = item
      @method = method
    end
  end
end
