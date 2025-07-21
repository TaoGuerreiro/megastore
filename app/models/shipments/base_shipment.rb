# frozen_string_literal: true

module Shipments
  class BaseShipment
    include ActiveModel::Model

    BASE_URL = "https://panel.sendcloud.sc/api/v2"
    SERVICE_POINT_BASE_URL = "https://servicepoints.sendcloud.sc/api/v2"

    attr_accessor :store, :from

    def initialize(store)
      @store = store
      @from = store.postal_code
      @token = encode_credentials(store.sendcloud_public_key, store.sendcloud_private_key)
      @points_token = encode_credentials(
        Rails.application.credentials.sendcloud.points_public_key,
        Rails.application.credentials.sendcloud.points_private_key
      )
    end

    protected

    def sendcloud_headers
      {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "Authorization" => "Basic #{@token}"
      }
    end

    def points_headers
      {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "Authorization" => "Basic #{@points_token}"
      }
    end

    def postale_headers(token)
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{token}",
        "Accept-Encoding" => "gzip"
      }
    end

    def postale_auth_headers
      {
        "Content-Type" => "application/x-www-form-urlencoded"
      }
    end

    def handle_api_response(response, context: "API call")
      return response.parsed_response if response.success?

      error_message = "API Error (#{context}): #{response.code} - #{response.body}"
      Rails.logger.error(error_message)
      raise ShipmentError, error_message
    end

    def log_operation(operation, details = {})
      Rails.logger.info(
        {
          operation: "Shipment #{operation}",
          store_id: @store.id,
          details:
        }
      )
    end

    def validate_required_params(params, required_keys)
      missing_keys = required_keys - params.keys.map(&:to_sym)
      return if missing_keys.empty?

      raise ArgumentError, "Missing required parameters: #{missing_keys.join(', ')}"
    end

    private

    def encode_credentials(public_key, private_key)
      Base64.strict_encode64("#{public_key}:#{private_key}")
    end

    def postale_credentials
      Rails.application.credentials.postale.send(Rails.env.to_s)
    end

    def postale_token
      @postale_token ||= fetch_postale_token
    end

    def fetch_postale_token
      url = postale_credentials.token_url
      body = {
        grant_type: "client_credentials",
        client_id: postale_credentials.client_id,
        client_secret: postale_credentials.client_secret
      }

      response = HTTParty.post(url, body:, headers: postale_auth_headers)
      handle_api_response(response, context: "Postale token")["access_token"]
    end

    def postage_data
      @postage_data ||= load_postage_data
    end

    def load_postage_data
      file_path = Rails.root.join("lib/poste.json")
      JSON.parse(File.read(file_path), symbolize_names: true)
    end
  end

  class ShipmentError < StandardError; end
end
