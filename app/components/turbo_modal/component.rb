# frozen_string_literal: true

class TurboModal::Component < ViewComponent::Base
  include Turbo::FramesHelper

  def initialize(title:)
    @title = title
  end

end
