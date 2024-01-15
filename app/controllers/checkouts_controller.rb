class CheckoutsController < ApplicationController
  before_action :set_order_intent, only: [:show, :shipping_method, :comfirm_payment]
  before_action :set_order, only: [:show, :shipping_method, :comfirm_payment]

  def add
    session[:checkout_items] = session[:checkout_items] || []
    @item = Item.find(params[:item_id])

    session[:checkout_items] << @item.id
    set_virtual_stock
    respond_to do |format|
      format.html { redirect_to item_path(@item), notice: "#{@item.name} ajouté au panier" }
      format.turbo_stream
    end
  end

  def remove
    session[:checkout_items] = session[:checkout_items] || []
    @item = Item.find(params[:item_id])
    session[:checkout_items].delete_at session[:checkout_items].index @item.id
    @opened = true

    set_virtual_stock
    respond_to do |format|
      format.html { redirect_to item_path(@item), notice: "#{@item.name} supprimé panier" }
      format.turbo_stream
    end
  end

  def show
    StripeConfigurationService.setup
    @items = Checkout.new(session[:checkout_items]).cart
    @order_intent = OrderIntent.new
    # authorize! :checkout TODO fix
  end

  def shipping_method
    @order.shipping_method = ShippingMethod.find(params[:order_intent][:shipping_method])
    @order_intent.shipping_method = ShippingMethod.find(params[:order_intent][:shipping_method])

    respond_to do |format|
      format.html { render "checkouts/show", status: :unprocessable_entity }
      format.turbo_stream
    end
  end

  def comfirm_payment
    unless @order_intent.valid?
      respond_to do |format|
        format.html { render "checkouts/show", status: :unprocessable_entity }
        format.turbo_stream
      end
      return
    end

    @order.assign_attributes(
      shipping_address: order_intent_params[:address],
      status: "confirmed",
      shipping_method: ShippingMethod.find(order_intent_params[:shipping_method]),
      user: user
    )

    # Enregistrez l'objet @order en premier
    if @order.save
      session = Stripe::Checkout::Session.create(
        payment_method_types: ['card'],
        customer_email: @order_intent.email,
        line_items: [{
          name: @order.order_items.first.item.name,
          images: nil,
          amount: @order.total_price_cents,
          currency: 'eur',
          quantity: 1
        }],
        success_url: order_url(@order),
        cancel_url: order_url(@order)
      )

      @order.update(checkout_session_id: session.id)

      respond_to do |format|
        format.html { render "checkouts/show", status: :unprocessable_entity }
        format.turbo_stream
      end
    else
      # Gérez l'erreur d'enregistrement de @order ici
      respond_to do |format|
        format.html { render "checkouts/show", status: :unprocessable_entity }
        format.turbo_stream
      end
    end
  end


  private

  def user
    User.find_or_create_by(email: order_intent_params[:email]) do |user|
      user.first_name = order_intent_params[:first_name]
      user.last_name = order_intent_params[:last_name]
      user.phone = order_intent_params[:phone]
      user.password = SecureRandom.hex(10)
    end
  end

  def set_order_intent
    @items = Checkout.new(session[:checkout_items]).cart
    @order_intent = OrderIntent.new(order_intent_params)
  end

  def set_order
    @total = Checkout.new(session[:checkout_items]).sum
    @order = Order.new({
        amount: @total,
        order_items: @items.map { |item| OrderItem.new(item: item[:item], quantity: item[:number]) }
    })
  end

  def order_intent_params
    return {} unless params[:order_intent]

    params.require(:order_intent).permit(:email, :first_name, :last_name, :address, :phone, :shipping_method)
  end

  def set_virtual_stock
    @item = Item.find(params[:item_id])
    cart_stock = Checkout.new(session[:checkout_items]).cart.find { |item| item[:item].id == @item.id }&.[](:number) || 0
    @virtual_stock = @item.stock - cart_stock
  end
end
