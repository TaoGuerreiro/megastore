# frozen_string_literal: true

class EndiServices
  class GetPdf < EndiServices
    include ApplicationHelper

    def initialize(order)
      super
      @url = "#{ENDI_PATH}/invoices/#{order.endi_id}.pdf"
    end

    def call
      headers = headers.merge("Referer" => @url)

      response = HTTParty.patch(@url, headers:)

      return unless response.code == 401

      EndiServices::ResetAuth.new.call
      HTTParty.patch(@url, headers:)
    end
  end
end
