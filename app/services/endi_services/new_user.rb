# frozen_string_literal: true

module EndiServices
  class NewUser
    include ApplicationHelper

    def initialize(store)
      @store = store
      @url = "#{Rails.application.credentials.endi.public_send(Rails.env).endi_path}/api/v1/companies/#{Rails.application.credentials.endi.public_send(Rails.env).endi_id}/customers"
    end

    def call
      EndiServices::ResetAuth.new(@store).call

      @token = EndiServices::GetCsrfToken.new(@store).call

      headers = {
        "Accept" => "*/*",
        "Content-Type" => "application/json",
        "Origin" => Rails.application.credentials.endi.public_send(Rails.env).endi_path.to_s,
        "Accept-Language" => "fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3",
        "Accept-Encoding" => "gzip, deflate, br",
        "Cookie" => @store.endi_auth,
        "Host" => Rails.application.credentials.endi.public_send(Rails.env).endi_host.to_s,
        "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/115.0",
        "Referer" => "#{Rails.application.credentials.endi.public_send(Rails.env).endi_path}/companies/#{Rails.application.credentials.endi.public_send(Rails.env).endi_id}/customers/add",
        "X-CSRFToken" => @token,
        "Content-Length" => "170",
        "Connection" => "keep-alive",
        "Sec-Fetch-Dest" => "empty",
        "Sec-Fetch-Mode" => "cors",
        "Sec-Fetch-Site" => "same-origin",
      }

      body = {
        "address" =>	@store.address,
        "city" =>	@store.city,
        "company_name" =>	@store.name,
        "country" =>	"FRANCE",
        "country_code" =>	"99100",
        "email" =>	@store.admin.email,
        "firstname" =>	@store.admin.first_name,
        "lastname" =>	@store.admin.last_name,
        "mobile" =>	@store.admin.phone,
        "type" =>	"company",
        "zip_code" =>	@store.postal_code,
        "csrf_token" => @token,
        "registration" =>	"provisoire"
      }.to_json

      response = HTTParty.post(@url, body:, headers:)

      if response.code == 401
        EndiServices::ResetAuth.new(@store).call
        response = HTTParty.post(@url, body:, headers:)
      end

      @store.update(endi_id: response["id"])

      EndiServices::AddUserToFolder.new(@store, response["id"]).call

      response
    end
  end
end
