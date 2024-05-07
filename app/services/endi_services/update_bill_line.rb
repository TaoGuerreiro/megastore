# frozen_string_literal: true

class EndiServices
  class UpdateBillLine < EndiServices
    include ApplicationHelper

    def initialize(order_item)
      super
      @order = order_item.order
      @order_item = order_item
      @line = line_id
      @url = <<-TXT
        #{ENDI_PATH}/api/v1/invoices/#{@order.endi_id}
        /task_line_groups/#{@line}/task_lines/#{@order_item.endi_line_id}
      TXT
    end

    def call
      headers = headers.merge("Referer" => @url)

      body = {
        order: "1",
        description: "#{type_of_item(@order_item)} du #{date_of_item(@order_item).strftime('%d/%m/%y')}",
        cost: (@order_item.orderable.price_cents / 100.00).to_s,
        quantity: "1",
        unity: "Unité",
        tva: "20",
        group_id: @line,
        product_id: "",
        mode: "ht"
      }.to_json

      response = HTTParty.patch(@url, headers:, body:)

      if response.code == 401
        EndiServices::ResetAuth.new.call
        response = HTTParty.patch(@url, headers:, body:)
      end

      response
    end

    private

    def type_of_item(order_item)
      if order_item.delivery?
        "Livraison"
      elsif order_item.tickets_book?
        "Carnet de tickets"
      elsif order_item.touring_book?
        "Tournée"
      else
        "Commande"
      end
    end

    def date_of_item(order_item)
      if order_item.delivery?
        order_item.orderable.drop_date
      elsif order_item.tickets_book? || order_item.touring_book?
        order_item.orderable.date_of_purchase
      end
    end

    def line_id
      url = "#{ENDI_PATH}/api/v1/invoices/#{@order.endi_id}/task_line_groups"
      headers = headers.merge("Referer" => url)

      response = HTTParty.get(url, headers:)
      if response.code == 401
        EndiServices::ResetAuth.new.call
        HTTParty.get(url, headers:)
      else
        response[0]["id"]
      end
    end
  end
end
