# frozen_string_literal: true

class EndiServices
  ENDI_PATH = Rails.application.credentials.endi.public_send(Rails.env).endi_path
  ENDI_ID = Rails.application.credentials.endi.public_send(Rails.env).endi_id
  ENDI_HOST = Rails.application.credentials.endi.public_send(Rails.env).endi_host
  ENDI_PASSWORD = Rails.application.credentials.endi.public_send(Rails.env).endi_password
  ENDI_USERNAME = Rails.application.credentials.endi.public_send(Rails.env).endi_username
  # rubocop:disable  Layout/LineLength
  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1.2 Safari/605.1.15"
  # rubocop:enable  Layout/LineLength
  def headers
    EndiServices::ResetAuth.new.call if Current.endi_auth.nil?

    @headers ||= {
      "Accept" => "application/json, text/javascript, */*; q=0.01",
      "Content-Type" => "application/json",
      "Origin" => ENDI_PATH.to_s,
      "Accept-Language" => "fr-fr",
      "Cache-Control" => "no-cache",
      "Cookie" => Current.endi_auth,
      "Host" => ENDI_HOST.to_s,
      "User-Agent" => USER_AGENT,
      "X-CSRFToken" => "undefined",
      "X-Requested-With" => "XMLHttpRequest",
      "Connection" => "keep-alive"
    }
  end

  def mechanize
    @mechanize ||= EndiServices::Auth.new.call
  end
end
