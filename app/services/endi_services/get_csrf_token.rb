# frozen_string_literal: true

class EndiServices
  class GetCsrfToken < EndiServices
    include ApplicationHelper

    def initialize
      super
      @url = build_url
      @referer = build_referer
    end

    def call
      headers = headers.merge("Referer" => @referer)
      perform_get_request(@url, headers)
    end

    private

    def build_url
      "#{ENDI_PATH}/api/v1/companies/#{ENDI_ID}/customers?form_config=1"
    end

    def build_referer
      "#{ENDI_PATH}/companies/#{ENDI_ID}/customers/add"
    end

    def perform_get_request(url, headers)
      response = HTTParty.get(url, headers:)

      if response.code == 401
        EndiServices::ResetAuth.new.call
        response = HTTParty.get(url, headers:)
      end

      extract_csrf_token(response)
    end

    def extract_csrf_token(response)
      response_body = response.parsed_response
      response_body.dig("schemas", "individual", "properties", "csrf_token", "default")
    end
  end
end
