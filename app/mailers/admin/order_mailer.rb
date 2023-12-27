
class Admin::OrderMailer < ApplicationMailer
  def payment_confirmation(order)
    @order = order
    # mail to: @order.user.email, subject: "Confirmation de paiement"
    items = @order.items.map do |item|
      {
        "description": item.name,
        "amount": item.price_cents,
      }
    end
    client = Postmark::ApiClient.new(@order.store.postmark_key)
    client.deliver_with_template({
      :from=> @order.store.admin.email,
      :to=> @order.user.email,
      :template_alias=> "receipt",
      :template_model=> {
        "product_url"=> @order.store.domain,
        "product_name"=> @order.store.name,
        "name"=> @order.user.email,
        "user_body_mail"=> @order.store.mail_body,
        "order_id"=> @order.id,
        "date"=> @order.created_at.strftime("%d/%m/%Y"),
        "receipt_details"=> items,
        "total"=> @order.amount,
        "store_username"=> @order.store.name,
        "company_name"=> @order.store.name
      }
    })
  end

  def new_order(order)
    @order = order
    @store = @order.items.first.store
    email = @store.admin.email
    mail to: email, subject: "Nouvelle commande"
  end
end
