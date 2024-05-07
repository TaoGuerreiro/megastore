# frozen_string_literal: true

module Cards
  class CardComponent < ViewComponent::Base
    attr_accessor :images, :link, :title

    def initialize(data = {})
      super
      @images = data[:images]
      @link = data[:link] || nil
      @title = data[:title] || nil
    end
  end
end
