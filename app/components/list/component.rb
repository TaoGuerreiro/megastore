module List
  class Component < ViewComponent::Base
    attr_accessor :links, :item

    def initialize(item:, links:)
      @item = item
      @links = links
    end
  end
end
