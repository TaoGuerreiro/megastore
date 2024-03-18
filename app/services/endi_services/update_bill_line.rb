# frozen_string_literal: true

module EndiServices
  class UpdateBillLine
    include ApplicationHelper

    def initialize(order_item, user)
      @mechanize = EndiServices::Auth.new.call
      @order = order_item.order
      @order_item = order_item
      @user = user
      @line = get_line_id
      @url = "#{Rails.application.credentials.endi.public_send(Rails.env).endi_path}/api/v1/invoices/#{@order.endi_id}/task_line_groups/#{@line}/task_lines/#{@order_item.endi_line_id}"
    end

    def call
      headers = {
        "Accept" => "application/json, text/javascript, */*; q=0.01",
        "Content-Type" => "application/json",
        "Origin" => Rails.application.credentials.endi.public_send(Rails.env).endi_path.to_s,
        "Accept-Language" => "fr-fr",
        "Cache-Control" => "no-cache",
        "Cookie" => @user.endi_auth,
        "Host" => Rails.application.credentials.endi.public_send(Rails.env).endi_host.to_s,
        "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1.2 Safari/605.1.15",
        "Referer" => @url,
        "X-CSRFToken" => "undefined",
        "X-Requested-With" => "XMLHttpRequest",
        "Connection" => "keep-alive"
      }

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
        EndiServices::ResetAuth.new(@user).call
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

    def get_line_id
      url = "#{Rails.application.credentials.endi.public_send(Rails.env).endi_path}/api/v1/invoices/#{@order.endi_id}/task_line_groups"

      headers = {
        "Accept" => "application/json, text/javascript, */*; q=0.01",
        "Content-Type" => "application/json",
        "Origin" => Rails.application.credentials.endi.public_send(Rails.env).endi_path.to_s,
        "Accept-Language" => "fr-fr",
        "Cache-Control" => "no-cache",
        "Cookie" => @user.endi_auth,
        "Host" => Rails.application.credentials.endi.public_send(Rails.env).endi_host.to_s,
        "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1.2 Safari/605.1.15",
        "Referer" => url,
        "X-CSRFToken" => "undefined",
        "X-Requested-With" => "XMLHttpRequest",
        "Connection" => "keep-alive"
      }

      response = HTTParty.get(url, headers:)
      if response.code == 401
        EndiServices::ResetAuth.new(@user).call
        HTTParty.get(url, headers:)
      else
        response[0]["id"]
      end
    end
  end
end
