# frozen_string_literal: true

class EndiServices
  class GetCsrfToken < EndiServices
    include ApplicationHelper

    def initialize
      super
      @url = build_url
      @referer = build_referer
      @headers = EndiServices.new.headers.merge("Referer" => @referer)
    end

    def call
      perform_get_request
    end

    private

    def build_url
      "#{ENDI_PATH}/api/v1/companies/#{ENDI_ID}/customers?form_config=1"
    end

    def build_referer
      "#{ENDI_PATH}/companies/#{ENDI_ID}/customers/add"
    end

    def perform_get_request
      response = HTTParty.get(@url, headers: @headers)

      if response.code == 401
        EndiServices::ResetAuth.new.call
        @headers = EndiServices.new.headers.merge("Referer" => @referer)
        response = HTTParty.get(@url, headers: @headers)
      end

      extract_csrf_token(response)
    end

    def extract_csrf_token(response)
      response_body = response.parsed_response
      response_body.dig("schemas", "individual", "properties", "csrf_token", "default")
    end
  end
end
