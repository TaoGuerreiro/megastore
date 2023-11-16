# frozen_string_literal: true

class SocialLinks::Component < ViewComponent::Base
  def initialize(color: "text-black")
    @color = color
  end
end
