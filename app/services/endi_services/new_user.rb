# frozen_string_literal: true

class EndiServices
  class NewUser < EndiServices
    include ApplicationHelper

    def initialize(store)
      super
      @store = store
      @url = "#{ENDI_PATH}/api/v1/companies/#{ENDI_ID}/customers"
    end

    def call
      @token = EndiServices::GetCsrfToken.new.call

      headers = headers.merge("Referer" => "#{ENDI_PATH}/companies/#{ENDI_ID}/customers/add")

      response = HTTParty.post(@url, body:, headers:)

      if response.code == 401
        EndiServices::ResetAuth.new.call
        response = HTTParty.post(@url, body:, headers:)
      end

      @store.update(endi_id: response["id"])

      EndiServices::AddUserToFolder.new(@store, response["id"]).call

      response
    end

    def body
      {
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
    end
  end
end
