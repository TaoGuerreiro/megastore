# frozen_string_literal: true

module EndiServices
  class GetInvoice < EndiService
    include ApplicationHelper

    def initialize(order)
      super
      @url = "#{ENDI_PATH}/api/v1/invoices/#{order.endi_id}"
    end

    def call
      header.merge("Referer" => @url)

      response = HTTParty.get(@url, headers:)
      if response.code == 401
        EndiServices::ResetAuth.new.call
        response = HTTParty.get(@url, headers:)
      end

      response
    end
  end
end
