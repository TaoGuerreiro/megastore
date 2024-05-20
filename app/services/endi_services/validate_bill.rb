# frozen_string_literal: true

module EndiServices
  class ValidateBill < EndiService
    include ApplicationHelper

    def initialize(order)
      super
      @order = order
      @url = "#{ENDI_PATH}/api/v1/invoices/#{@order.endi_id}?action=status"
    end

    def call
      headers = headers.merge("Referer" => @url)

      body = {
        submit:	"valid",
        comment: t(".comment")
      }.to_json

      response = HTTParty.post(@url, headers:, body:)
      if response.code == 401
        EndiServices::ResetAuth.new.call
        response = HTTParty.post(@url, headers:, body:)
      end
      response
    end
  end
end
