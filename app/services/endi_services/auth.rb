# frozen_string_literal: true

module EndiServices
  class Auth
    include ApplicationHelper

    def call
      url = Rails.application.credentials.endi.public_send(Rails.env).endi_path
      mechanize = Mechanize.new

      mechanize.request_headers["Host"] = Rails.application.credentials.endi.public_send(Rails.env).endi_host.to_s
      mechanize.request_headers["User-Agent"] =
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/114.0"
      mechanize.request_headers["Accept"] =
        "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8"
      mechanize.request_headers["Accept-Language"] = "fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3"
      mechanize.request_headers["Accept-Encoding"] = "gzip, deflate, br"
      mechanize.request_headers["Referer"] = Rails.application.credentials.endi.public_send(Rails.env).endi_path.to_s
      mechanize.request_headers["Connection"] = "keep-alive"
      mechanize.request_headers["Upgrade-Insecure-Requests"] = "1"
      mechanize.request_headers["Sec-Fetch-Dest"] = "document"
      mechanize.request_headers["Sec-Fetch-Mode"] = "navigate"
      mechanize.request_headers["Sec-Fetch-Site"] = "same-origin"

      page = mechanize.get(url)

      form = page.form_with(id: "authentication")

      form.login = Rails.application.credentials.endi.public_send(Rails.env).endi_username
      form.password = Rails.application.credentials.endi.public_send(Rails.env).endi_password

      form.click_button

      mechanize
    end
  end
end
