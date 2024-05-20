# frozen_string_literal: true

module Tooltip
  class Component < ViewComponent::Base
    def initialize(message:)
      super
      @message = message
    end
  end
end
