# frozen_string_literal: true

module EndiServices
  class NewMemo
    include ApplicationHelper

    def initialize(order, title, content)
      @order = order
      @title = title
      @content = content
      @user = order.user
      @url = "#{Rails.application.credentials.endi.public_send(Rails.env).endi_path}/api/v1/invoices/#{@order.endi_id}/statuslogentries"
    end

    def call
      response = HTTParty.post(@url, body: body.to_json, headers:)

      if response.code == 401
        EndiServices::ResetAuth.new(@user).call
        response = HTTParty.post(@url, body: body.to_json, headers:)
      end

      response&.response&.message
    end

    def body
      {
        "label" => @title,
        "comment" => @content,
        pinned: "true",
        "visibility" => "public"
      }
    end

    def headers
      {
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
    end
  end
end
