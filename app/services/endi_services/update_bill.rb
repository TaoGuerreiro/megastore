# frozen_string_literal: true

module EndiServices
  class UpdateBill
    include ApplicationHelper

    def initialize(order, store)
      @order = order
      @store = store
      @url = "#{Rails.application.credentials.endi.public_send(Rails.env).endi_path}/api/v1/invoices/#{@order.endi_id}"
    end

    def call
      invoice_headers = {
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

      invoice_body = {
        name:	"Facture pour la commande #{@order.id}",
        date:	@order.date.strftime("%Y-%m-%d"),
        payment_conditions: "À réception de la facture",
        description:	"Facturation du #{@order.date.strftime('%d/%m/%y')}",
        start_date:	@order.date.beginning_of_month.strftime("%Y-%m-%d"),
        end_date:	@order.date.end_of_month.strftime("%d/%m/%y"),
        workplace:	"Worlwide",
        display_units:	"1",
        display_ttc:	"0"
      }.to_json

      response = HTTParty.patch(@url, headers: invoice_headers, body: invoice_body)
      if response.code == 401
        EndiServices::ResetAuth.new(@store).call
        response = HTTParty.patch(@url, headers: invoice_headers, body: invoice_body)
      end
      response
    end
  end
end
