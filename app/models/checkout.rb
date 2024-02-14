class Checkout
  def initialize(ids)
    set_ids(ids)
  end

  def cart
    return [] if @ids.nil?

    unique_ids = @ids.uniq
    cart = unique_ids.map do |id|
      next unless Item.where(id: id).present?

      {
        item: Item.find(id),
        number: @ids.count(id)
      }
    end

    cart.first.blank? ? [] : cart
  end

  def sum
    return if @ids.nil?

    items = Item.where(id: @ids.uniq)
    sum = 0
    @ids.uniq.each do |id|
      item = items.find { |i| i.id == id }
      next unless item

      sum += item.price_cents * @ids.count(id)
    end
    sum / 100.00
  end

  def weight
    return if @ids.nil?

    items = Item.where(id: @ids.uniq)
    weight = 0
    @ids.each do |id|
      item = items.find { |i| i.id == id }
      next unless item

      weight += item.weight
    end
    weight
  end

  def all
    Item.where(id: @ids)
  end

  private

  def set_ids(ids)
    @ids = if ids.is_a?(Array)
      ids
    elsif ids.nil?
      []
    else
      ids.order_items.flat_map { |order_item| [order_item.item_id] * order_item.quantity }
    end
  end
end
