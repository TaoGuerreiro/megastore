class CheckoutsController < ApplicationController
  before_action :set_order_intent, only: [:show, :payment_method, :comfirm_payment]
  before_action :set_order, only: [:show, :payment_method, :comfirm_payment]

  def add
    session[:checkout_items] = session[:checkout_items] || []
    @item = Item.find(params[:item_id])
    session[:checkout_items] << @item.id

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
    respond_to do |format|
      format.html { redirect_to item_path(@item), notice: "#{@item.name} supprimé panier" }
      format.turbo_stream
    end
  end

  def show
    @items = Checkout.new(session[:checkout_items]).cart
    @order_intent = OrderIntent.new
  end

  def payment_method
    set_order_intent
    @order.payment_method = PaymentMethod.find(params[:order_intent][:payment_method])

    respond_to do |format|
      format.html { render "checkouts/show", status: :unprocessable_entity }
      format.turbo_stream
    end
  end

  def comfirm_payment
    # binding.pry
    unless @order_intent.valid?
      respond_to do |format|
        format.html { render "checkouts/show", status: :unprocessable_entity }
        format.turbo_stream
      end
      return
    end

    @order.status = "confirmed"
    @order.payment_method = PaymentMethod.first
    @order.user = user

    # Enregistrez l'objet @order en premier
    if @order.save
      session = Stripe::Checkout::Session.create(
        payment_method_types: ['card'],
        line_items: [{
          name: "teddy.sku",
          images: nil,
          amount: @order.amount_cents,
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

    params.require(:order_intent).permit(:email, :first_name, :last_name, :address, :phone, :payment_method)
  end
end
