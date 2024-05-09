# frozen_string_literal: true

class EndiServices
  class RemoveBillLine < EndiServices
    include ApplicationHelper

    def initialize(order_item)
      super
      @order = order_item.order
      @order_item = order_item
      @url = build_url
    end

    def call
      headers = headers.merge("Referer" => @url)
      perform_delete_request(@url, headers)
    end

    private

    def build_url
      line_id = fetch_line_id
      <<-TXT.squish!
        #{ENDI_PATH}/api/v1/invoices/#{@order.endi_id}/task_line_groups/
        #{line_id}/task_lines/#{@order_item.endi_line_id}
      TXT
    end

    def fetch_line_id
      url = "#{ENDI_PATH}/api/v1/invoices/#{@order.endi_id}/task_line_groups"
      headers = headers.merge("Referer" => url)
      response = HTTParty.get(url, headers:)

      if response.code == 401
        EndiServices::ResetAuth.new.call
        fetch_line_id
      else
        response[0]["id"]
      end
    end

    def perform_delete_request(url, headers)
      response = HTTParty.delete(url, headers:)

      if response.code == 401
        EndiServices::ResetAuth.new.call
        response = HTTParty.delete(url, headers:)
      end

      response
    end
  end
end
