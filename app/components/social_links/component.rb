# frozen_string_literal: true

class SocialLinks::Component < ViewComponent::Base
  def initialize(color: "text-constrast")
    @color = color
  end
end
