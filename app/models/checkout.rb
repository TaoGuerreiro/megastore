class Checkout
  def initialize(ids)
    @ids = ids
  end

  def cart
    unique_ids = @ids.uniq
    cart = unique_ids.map do |id|
      next unless Item.where(id: id).present?

      {
        item: Item.find(id),
        number: @ids.count(id)
      }
    end
    cart.first.nil? ? [] : cart
  end

  def sum
    # raise
    unique_ids = @ids.uniq
    sum = 0
    unique_ids.map do |id|
      next unless Item.where(id: id).present?

      sum += Item.find(id).price_cents * @ids.count(id)
    end
    sum / 100.00
  end

  def all
    Item.where(@ids)
  end
end
