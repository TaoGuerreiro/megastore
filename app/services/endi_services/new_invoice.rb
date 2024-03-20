# frozen_string_literal: true

module EndiServices
  class NewInvoice
    include ApplicationHelper

    def initialize(order, store)
      @store = store
      @order = order
      @url = "#{Rails.application.credentials.endi.public_send(Rails.env).endi_path}/api/v1/companies/#{Rails.application.credentials.endi.public_send(Rails.env).endi_id}/invoices/add?company_id=#{Rails.application.credentials.endi.public_send(Rails.env).endi_id}"
    end

    def call
      @order.update(status: "processing", api_error: nil)
      response = HTTParty.post(@url, body: body.to_json, headers:)
      if response.code == 401
        EndiServices::ResetAuth.new(@store).call
        response = HTTParty.post(@url, body: body.to_json, headers:)
      elsif response.code == 200
        @order.update!(endi_id: response["id"], status: "draft")
        EndiServices::UpdateBill.new(@order, @store).call
        @order.update!(status: "pending")
        return response&.response&.message
      else
        @order.update!(status: "failed", api_error: response.to_s)
      end
    end

    def body
      body = {
        "name" => "Facture pour #{@store.name}",
        "customer_id" => @store.endi_id,
        "project_id" => Rails.application.credentials.endi.public_send(Rails.env).project_id.to_s,
        "business_type_id" => "2"
      }

      body
    end

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
  end
end
