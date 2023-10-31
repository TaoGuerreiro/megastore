class Checkout
  def initialize(ids)
    @ids = ids
  end

  def cart
    unique_ids = @ids.uniq
    cart = unique_ids.map do |id|
      {
        item: Item.find(id),
        number: @ids.count(id)
      }
    end
      cart
  end

  private

  def set_cart

  end
end
