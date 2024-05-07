# frozen_string_literal: true

class EndiServices
  class UpdateClient < EndiServices
    include ApplicationHelper

    def initialize(user)
      super
      @user = user
      @url = "#{ENDI_PATH}/api/v1/customers/#{user.endi_id}"
    end

    def call
      @token = EndiServices::GetCsrfToken.new.call
      headers = headers.merge("Referer" => @url)

      response = HTTParty.patch(@url, headers:, body:)
      if response.code == 401
        EndiServices::ResetAuth.new.call
        response = HTTParty.patch(@url, headers:, body:)
      end
      response
    end

    def body
      {
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
    end
  end
end
