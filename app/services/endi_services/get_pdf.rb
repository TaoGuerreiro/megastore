# frozen_string_literal: true

module EndiServices
  class GetPdf
    include ApplicationHelper

    def initialize(order, user)
      @order = order
      @user = user
      @url = "#{Rails.application.credentials.endi.public_send(Rails.env).endi_path}/invoices/#{@order.endi_id}.pdf"
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

      response = HTTParty.patch(@url, headers: invoice_headers)

      return unless response.code == 401

      EndiServices::ResetAuth.new(@user).call
      HTTParty.patch(@url, headers: invoice_headers)
    end
  end
end
