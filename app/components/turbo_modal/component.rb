# frozen_string_literal: true

module TurboModal
  class Component < ViewComponent::Base
    include Turbo::FramesHelper

    def initialize(title:)
      super
      @title = title
    end
  end
end
