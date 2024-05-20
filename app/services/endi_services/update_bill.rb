# frozen_string_literal: true

module EndiServices
  class UpdateBill < EndiService
    include ApplicationHelper

    def initialize(order, store)
      super()
      @order = order
      @store = store
      @url = "#{ENDI_PATH}/api/v1/invoices/#{@order.endi_id}"
      @headers = EndiService.new.headers
    end

    def call
      @headers = @headers.merge("Referer" => @url)

      response = HTTParty.patch(@url, headers: @headers, body:)
      if response.code == 401
        EndiServices::ResetAuth.new.call
        @headers = EndiService.new.headers
        response = HTTParty.patch(@url, headers: @headers, body:)
      end

      response
    end

    def body
      {
        name: "Facture pour #{@store.name}",
        date:	@order.date.strftime("%Y-%m-%d"),
        payment_conditions: "À réception de la facture",
        description:	"Facturation du #{@order.date.strftime('%d/%m/%y')}",
        start_date:	@order.date.beginning_of_month.strftime("%Y-%m-%d"),
        end_date:	@order.date.end_of_month.strftime("%d/%m/%y"),
        workplace:	"Worlwide",
        display_units:	"1",
        display_ttc:	"0"
      }.to_json
    end
  end
end
