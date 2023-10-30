# frozen_string_literal: true

class Cards::CardComponent < ViewComponent::Base
  attr_accessor :images, :link, :title

  def initialize(data = {})
    @images = data[:images]
    @link = data[:link] || nil
    @title = data[:title] || nil
  end
end
