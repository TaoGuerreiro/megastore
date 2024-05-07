# frozen_string_literal: true

class EndiServices
  class RemoveBill < EndiServices
    include ApplicationHelper

    def initialize(order)
      super
      @url = "#{ENDI_PATH}/api/v1/invoices/#{order.endi_id}"
    end

    def call
      headers = headers.merge("Referer" => @url)

      response = HTTParty.delete(@url, headers:)
      if response.code == 401
        EndiServices::ResetAuth.new.call
        response = HTTParty.delete(@url, headers:)
      end
      response
    end
  end
end
