# frozen_string_literal: true

class EndiServices
  class NewMemo < EndiServices
    include ApplicationHelper

    def initialize(order, title, content)
      super
      @title = title
      @content = content
      @url = "#{ENDI_PATH}/api/v1/invoices/#{order.endi_id}/statuslogentries"
    end

    def call
      header.merge("Referer" => @url)

      response = HTTParty.post(@url, body:, headers:)

      if response.code == 401
        EndiServices::ResetAuth.new.call
        response = HTTParty.post(@url, body:, headers:)
      end

      response&.response&.message
    end

    def body
      {
        "label" => @title,
        "comment" => @content,
        pinned: "true",
        "visibility" => "public"
      }.to_json
    end
  end
end
