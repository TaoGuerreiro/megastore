# frozen_string_literal: true

module EndiServices
  class UpdateClient
    include ApplicationHelper

    def initialize(user)
      @user = user
      @url = "#{Rails.application.credentials.endi.public_send(Rails.env).endi_path}/api/v1/customers/#{user.endi_id}"
    end

    def call
      EndiServices::ResetAuth.new(@user).call

      @token = EndiServices::GetCsrfToken.new(@user).call

      invoice_headers = {
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

      invoice_body = {
        "address" =>	@user.street,
        "city" =>	@user.user_city,
        "company_name" =>	@user.company,
        "country" =>	"FRANCE",
        "country_code" =>	"99100",
        "email" =>	@user.email,
        "firstname" =>	@user.first_name,
        "lastname" =>	@user.last_name,
        "mobile" =>	@user.phone,
        "type" =>	"company",
        "zip_code" =>	@user.zip_code,
        "csrf_token" => @token
      }.to_json

      response = HTTParty.patch(@url, headers: invoice_headers, body: invoice_body)
      if response.code == 401
        EndiServices::ResetAuth.new(@user).call
        response = HTTParty.patch(@url, headers: invoice_headers, body: invoice_body)
      end
      response
    end
  end
end
