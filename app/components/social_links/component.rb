# frozen_string_literal: true

module SocialLinks
  class Component < ViewComponent::Base
    def initialize(color: "text-constrast")
      super
      @color = color
    end
  end
end
