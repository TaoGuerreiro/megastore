# frozen_string_literal: true

module EndiServices
  class NewInvoice < EndiService
    include ApplicationHelper

    def initialize(order, store)
      super()
      @store = store
      @order = order
      @url = "#{ENDI_PATH}/api/v1/companies/#{ENDI_ID}/invoices/add?company_id=#{ENDI_ID}"
      @headers = EndiService.new.headers
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def call
      @headers.merge("Referer" => @url)

      @order.update(status: "processing", api_error: nil)
      response = HTTParty.post(@url, body:, headers: @headers)
      if response.code == 401
        EndiServices::ResetAuth.new.call
        @headers = EndiService.new.headers
        response = HTTParty.post(@url, body:, headers: @headers)
      end

      if response.code == 200
        @order.update!(endi_id: response["id"], status: "draft")
        EndiServices::UpdateBill.new(@order, @store).call
        @order.update!(status: "pending")
        response&.response&.message
      else
        @order.update!(status: "failed", api_error: response.to_s)
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def body
      {
        "name" => "Facture pour #{@store.name}",
        "customer_id" => @store.endi_id,
        "project_id" => Rails.application.credentials.endi.public_send(Rails.env).project_id.to_s,
        "business_type_id" => "2"
      }.to_json
    end
  end
end
