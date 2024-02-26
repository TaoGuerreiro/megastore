# frozen_string_literal: true

module Admin
  class OrderMailer < ApplicationMailer
    def payment_confirmation(order)
      @order = order
      items = @order.items.map do |item|
        {
          "description": item.name,
          "amount": item.price_cents / 100.00,
          "currency": t(item.price_currency),
        }
      end
      client = Postmark::ApiClient.new(@order.store.postmark_key)
      currency = t(@order.amount_currency)

      client.deliver_with_template({
                                     from: @order.store.admin.email,
                                     to: @order.user.email,
                                     template_alias: 'receipt',
                                     template_model: {
                                       'product_url' => @order.store.domain,
                                       'product_name' => @order.store.name,
                                       'name' => @order.user.email,
                                       'user_body_mail' => @order.store.mail_body,
                                       'order_id' => @order.id,
                                       'date' => @order.created_at.strftime('%d/%m/%Y'),
                                       'receipt_details' => items,
                                       'total' => @order.amount_cents / 100.00,
                                       'store_username' => @order.store.name,
                                       'company_name' => @order.store.name,
                                       'currency' => currency,
                                     }
                                   })
    end

    def new_order(order)
      @order = order
      @store = @order.items.first.store
      email = @store.admin.email
      mail to: email, subject: 'Nouvelle commande'
    end
  end
end
