# frozen_string_literal: true

module EndiServices
  class AddBillLine
    include ApplicationHelper

    def initialize(order_item, store)
      @order = order_item.store_order
      @order_item = order_item
      @store = store
      @line = get_line_id
      @url = "#{Rails.application.credentials.endi.public_send(Rails.env).endi_path}/api/v1/invoices/#{@order.endi_id}/task_line_groups/#{@line}/task_lines"
    end

    def call
      attempts ||= 1
      response = HTTParty.post(@url, headers:, body:)
      raise "connection to endi failed" if response.code == 401

      @order_item.update(endi_line_id: response["id"])
      response&.response&.message
    rescue StandardError
      if (attempts += 1) < 5
        EndiServices::ResetAuth.new(@store).call
        retry
      else
        @order.update(status: "error")
      end
    end

    private

    def headers
      {
        "Accept" => "application/json, text/javascript, */*; q=0.01",
        "Content-Type" => "application/json",
        "Origin" => Rails.application.credentials.endi.public_send(Rails.env).endi_path.to_s,
        "Accept-Language" => "fr-fr",
        "Cache-Control" => "no-cache",
        "Cookie" => @store.endi_auth,
        "Host" => Rails.application.credentials.endi.public_send(Rails.env).endi_host.to_s,
        "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1.2 Safari/605.1.15",
        "Referer" => @url,
        "X-CSRFToken" => "undefined",
        "X-Requested-With" => "XMLHttpRequest",
        "Connection" => "keep-alive"
      }
    end

    def body
      description = I18n.t("endi.#{@order_item.orderable_name}", order_id: @order_item.orderable.order.id)

      body = {
        order: "1",
        description:,
        cost: @order_item.price_cents / 100.0,
        quantity: "1",
        tva: "20",
        group_id: @line,
        mode: "ht",
      }

      body[:unity] = Rails.env.production? ? "Unité" : "unité(s)"

      body.to_json
    end

    def get_line_id
      url = "#{Rails.application.credentials.endi.public_send(Rails.env).endi_path}/api/v1/invoices/#{@order.endi_id}/task_line_groups"

      headers = {
        "Accept" => "application/json, text/javascript, */*; q=0.01",
        "Content-Type" => "application/json",
        "Origin" => Rails.application.credentials.endi.public_send(Rails.env).endi_path.to_s,
        "Accept-Language" => "fr-fr",
        "Cache-Control" => "no-cache",
        "Cookie" => @store.endi_auth,
        "Host" => Rails.application.credentials.endi.public_send(Rails.env).endi_host.to_s,
        "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1.2 Safari/605.1.15",
        "Referer" => url,
        "X-CSRFToken" => "undefined",
        "X-Requested-With" => "XMLHttpRequest",
        "Connection" => "keep-alive"
      }

      response = HTTParty.get(url, headers:)

      if response.code == 401
        EndiServices::ResetAuth.new(@store).call
        HTTParty.get(url, headers:)
      else
        response[0]["id"]
      end
    end
  end
end
