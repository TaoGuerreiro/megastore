# frozen_string_literal: true

module Cards
  class CardComponent < ViewComponent::Base
    attr_accessor :card

    def initialize(card:)
      @card = card
    end
  end
end
