# frozen_string_literal: true

class Cart::Component < ViewComponent::Base
  def items
    Checkout.new(session[:checkout_items]).cart
  end

  def total
    Checkout.new(session[:checkout_items]).sum
  end
end
