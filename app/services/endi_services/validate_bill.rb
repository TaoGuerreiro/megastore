# frozen_string_literal: true

module EndiServices
  class ValidateBill
    include ApplicationHelper

    def initialize(order, user)
      @order = order
      @user = user
      @url = "#{Rails.application.credentials.endi.public_send(Rails.env).endi_path}/api/v1/invoices/#{@order.endi_id}?action=status"
    end

    def call

      invoice_headers = {
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

      invoice_body = {
        submit:	"valid",
        comment: "Cette facture est générée directement par notre application, si il y a le moindre soucis n'hésitez pas à me contacter (Florent) au 0781116670 😊"
      }.to_json

      response = HTTParty.post(@url, headers: invoice_headers, body: invoice_body)
      if response.code == 401
        EndiServices::ResetAuth.new(@user).call
        response = HTTParty.post(@url, headers: invoice_headers, body: invoice_body)
      end
      response
    end
  end
end
