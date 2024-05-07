# frozen_string_literal: true

module EndiServices
  class NewInvoice
    def initialize(order, store)
      @order = order
      @store = store
      @url = "your_endpoint_here"
      @headers = { "Content-Type" => "application/json" }
    end

    def call
      prepare_order
      response = send_request

      case response.code
      when 401
        handle_unauthorized
      when 200
        handle_success(response)
      else
        handle_failure(response)
      end
    end

    private

    def prepare_order
      @order.update(status: "processing", api_error: nil)
    end

    def send_request
      HTTParty.post(@url, body:, headers: @headers)
    end

    def body
      {
        "name" => "Facture pour #{@store.name}",
        "customer_id" => @store.endi_id,
        "project_id" => Rails.application.credentials.endi.public_send(Rails.env).project_id.to_s,
        "business_type_id" => "2"
      }.to_json
    end

    def handle_unauthorized
      EndiServices::ResetAuth.new.call
      HTTParty.post(@url, body:, headers: @headers)
    end

    def handle_success(response)
      @order.update!(endi_id: response["id"], status: "draft")
      EndiServices::UpdateBill.new(@order, @store).call
      @order.update!(status: "pending")
      response&.response&.message
    end

    def handle_failure(response)
      @order.update!(status: "failed", api_error: response.to_s)
    end
  end
end
