# frozen_string_literal: true

class EndiServices
  class Auth < EndiServices
    include ApplicationHelper

    def call
      initialize_mechanize
      set_headers
      submit_authentication_form
    end

    private

    def initialize_mechanize
      @mechanize = Mechanize.new
    end

    def set_headers
      @mechanize.request_headers = default_request_headers
    end

    def default_request_headers
      {
        "Host" => ENDI_HOST.to_s,
        "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/114.0",
        "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
        "Accept-Language" => "fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3",
        "Accept-Encoding" => "gzip, deflate, br",
        "Referer" => ENDI_PATH.to_s,
        "Connection" => "keep-alive",
        "Upgrade-Insecure-Requests" => "1",
        "Sec-Fetch-Dest" => "document",
        "Sec-Fetch-Mode" => "navigate",
        "Sec-Fetch-Site" => "same-origin"
      }
    end

    def submit_authentication_form
      page = @mechanize.get(ENDI_PATH)
      form = page.form_with(id: "authentication")
      form.login = ENDI_USERNAME
      form.password = ENDI_PASSWORD
      form.click_button
      @mechanize
    end
  end
end
