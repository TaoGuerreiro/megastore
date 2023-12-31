class Checkout
  def initialize(ids)
    set_ids(ids)
    # @ids = ids
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

    unique_ids = @ids.uniq
    sum = 0
    unique_ids.map do |id|
      next unless Item.where(id: id).present?

      sum += Item.find(id).price_cents * @ids.count(id)
    end
    sum / 100.00
  end

  def weight
    return if @ids.nil?

    weight = 0
    @ids.map do |id|
      next unless Item.where(id: id).present?

      weight += Item.find(id).weight
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
    else
      ids.order_items.flat_map { |order_item| [order_item.item_id] * order_item.quantity }
    end
  end
end
