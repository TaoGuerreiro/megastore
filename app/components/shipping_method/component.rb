# frozen_string_literal: true

module ShippingMethod
  class Component < ViewComponent::Base
    def initialize(field:, shipping_method:)
      @field = field
      @shipping_method = shipping_method
      @item = field.object
    end
    attr_reader :field, :shipping_method

    def checked
      if @item.is_a?(OrderIntent)
        @item.shipping_method == @shipping_method
      elsif @item.is_a?(Item)
        @item.shipping_methods.pluck(:id).include?(shipping_method.id)
      else
        false
      end
    end

    def js_controller
      "autosave" if @item.is_a?(OrderIntent)
    end
  end
end
