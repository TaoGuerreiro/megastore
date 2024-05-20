# frozen_string_literal: true

module EndiServices
  class AddBillLine < EndiService
    include ApplicationHelper

    def initialize(order_item, store)
      super()
      @order = order_item.store_order
      @order_item = order_item
      @store = store
      @line = line_id
      @url = "#{ENDI_PATH}/api/v1/invoices/#{@order.endi_id}/task_line_groups/#{@line}/task_lines"
    end

    def call
      headers = build_headers
      response = send_request(headers)

      handle_response(response)
    end

    private

    def build_headers
      headers = {}
      headers["Referer"] = @url
      headers
    end

    def send_request(headers)
      @attempts ||= 1
      response = HTTParty.post(@url, headers:, body:)
      raise "Connection to endi failed" if response.code == 401

      @order_item.update(endi_line_id: response["id"])
      response
    rescue StandardError
      handle_retry
    end

    def body
      description = I18n.t("endi.#{@order_item.orderable_name}", order_id: @order_item.orderable.order.id)

      {
        order: "1",
        description:,
        cost: @order_item.price_cents / 100.0,
        quantity: "1",
        product_id: "",
        tva: "20",
        group_id: @line,
        mode: "ht",
        unity: Rails.env.production? ? "Unité" : "unité(s)"
      }.to_json
    end

    def line_id
      url = "#{ENDI_PATH}/api/v1/invoices/#{@order.endi_id}/task_line_groups"
      headers = { "Referer" => url }

      response = HTTParty.get(url, headers:)

      if response.code == 401
        EndiServices::ResetAuth.new.call
        @headers = EndiService.new.headers
        response = HTTParty.get(url, headers: @headers)
      end
      response[0]["id"]
    end

    def handle_retry
      if (@attempts += 1) < 5
        EndiServices::ResetAuth.new.call
        @headers = EndiService.new.headers
        send_request(@headers)
      else
        @order.update(status: "error")
      end
    end

    def handle_response(response)
      response&.response&.message
    end
  end
end
