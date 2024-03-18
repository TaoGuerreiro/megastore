# frozen_string_literal: true

module EndiServices
  class NewInvoice
    include ApplicationHelper

    def initialize(order, user)
      @user = user
      @order = order
      @url = "#{Rails.application.credentials.endi.public_send(Rails.env).endi_path}/api/v1/companies/#{Rails.application.credentials.endi.public_send(Rails.env).endi_id}/invoices/add?project_id=#{Rails.application.credentials.endi.public_send(Rails.env).project_id}"
    end

    def call
      response = HTTParty.post(@url, body: body.to_json, headers:)
      if response.code == 401
        EndiServices::ResetAuth.new(@user).call
        response = HTTParty.post(@url, body: body.to_json, headers:)
      end

      @order.update!(endi_id: response["id"], status: "draft")

      EndiServices::UpdateBill.new(@order, @user).call

      response&.response&.message
    end

    def body
      body = {
        "name" => "Facture pour la commande #{@order.id}",
        "customer_id" => @order.user.endi_id,
        "project_id" => Rails.application.credentials.endi.public_send(Rails.env).project_id.to_s,
        "business_type_id" => "2"
      }

      body["phase_id"] = "87" if Rails.env.production?
      body
    end

    def headers
      {
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
    end
  end
end
