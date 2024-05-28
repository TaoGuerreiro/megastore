# frozen_string_literal: true

module EndiServices
  class TaskLineGroup < EndiService
    include ApplicationHelper

    def initialize(order, _store)
      super()
      @order = order
      @url = "#{ENDI_PATH}/api/v1/invoices/#{@order.endi_id}/task_line_groups"
    end

    def call
      headers = build_headers

      response = HTTParty.get(@url, headers:)

      if response.code == 401
        EndiServices::ResetAuth.new.call
        @headers = EndiService.new.headers
        response = HTTParty.get(@url, headers: @headers)
      end
      response[0]["id"]
    end

    private

    def build_headers
      headers = {}
      headers["Referer"] = @url
      headers
    end
  end
end
