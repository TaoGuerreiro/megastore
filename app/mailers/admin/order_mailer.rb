# frozen_string_literal: true

module Admin
  class OrderMailer < ApplicationMailer
    def payment_confirmation(order)
      @order = order
      @items = @order.items.map do |item|
        {
          description: item.name,
          amount: number_to_currency(item.price_cents / 100.00, unit: I18n.t(item.price_currency))
        }
      end
      client.deliver_with_template(body)
    end

    def new_order(order)
      @order = order
      @store = @order.items.first.store
      email = @store.admin.email
      mail to: email, subject: t(".subject")
    end

    private

    def client
      @client ||= Postmark::ApiClient.new(Rails.application.credentials.postmark_api_token.send(Rails.env))
    end

    def body
      {
        from: "transaction@chalky.fr",
        to: @order.user.email,
        template_alias: "chalky_receipt",
        template_model: {
          "product_url" => @order.store.domain,
          "product_name" => @order.store.name,
          "name" => @order.user.email,
          "user_body_mail" => @order.store.mail_body,
          "order_id" => @order.id,
          "date" => @order.created_at.strftime("%d/%m/%Y"),
          "receipt_details" => @items,
          "total" => number_to_currency(@order.amount_cents / 100.00,
                                        unit: I18n.t(@order.amount_currency)),
          "store_username" => @order.store.name,
          "company_name" => @order.store.name
        }
      }
    end
  end
end
