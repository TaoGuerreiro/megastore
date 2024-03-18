# frozen_string_literal: true

module EndiServices
  class NewUser
    include ApplicationHelper

    def initialize(user)
      @user = user
      @url = "#{Rails.application.credentials.endi.public_send(Rails.env).endi_path}/api/v1/companies/#{Rails.application.credentials.endi.public_send(Rails.env).endi_id}/customers"
    end

    def call
      EndiServices::ResetAuth.new(@user).call

      @token = EndiServices::GetCsrfToken.new(@user).call

      headers = {
        "Accept" => "*/*",
        "Content-Type" => "application/json",
        "Origin" => Rails.application.credentials.endi.public_send(Rails.env).endi_path.to_s,
        "Accept-Language" => "fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3",
        "Accept-Encoding" => "gzip, deflate, br",
        "Cookie" => @user.endi_auth,
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
        "csrf_token" => @token,
        "registration" =>	"provisoire"
      }.to_json

      response = HTTParty.post(@url, body:, headers:)

      if response.code == 401
        EndiServices::ResetAuth.new(@user).call
        response = HTTParty.post(@url, body:, headers:)
      end

      @user.update(endi_id: response["id"])

      EndiServices::AddUserToFolder.new(@user, response["id"]).call

      response
    rescue StandardError => e
      SlackMessageJob.perform_later(title: "⚠️ Attention ⚠️", content: "Impossible d'ajouter #{@user.email} à Endi (L'ajouter à la main et renseigner son endi_id manuellement dans l'app Bicicouriers)", channel: "general")
      DiscordMessageJob.perform_later(title: "⚠️ Attention ⚠️", content: "Impossible d'ajouter #{@user.email} à Endi (L'ajouter à la main et renseigner son endi_id manuellement dans l'app Bicicouriers)", channel: "general")
      { status: false, message: e }
    end
  end
end
