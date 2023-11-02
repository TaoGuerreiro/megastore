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

  def sum
    unique_ids = @ids.uniq
    sum = 0
    unique_ids.map do |id|
      sum += Item.find(id).price_cents * @ids.count(id)
    end
    sum / 100.00
  end

  def all
    Item.where(@ids)
  end
end
