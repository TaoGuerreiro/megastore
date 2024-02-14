class Shipment
  include ActiveModel::Model

  BASE_URL = "https://panel.sendcloud.sc/api/v2"
  SERVICE_POINT_BASE_URL = "https://servicepoints.sendcloud.sc/api/v2"

  attr_accessor :from

  def initialize(store)
    @token = encode_credentials(store.sendcloud_public_key, store.sendcloud_private_key)
    @points_token = encode_credentials("221e3d39-5789-4b00-998b-ec2a0a744025", "9a8b9973605f4b09b97efb61001f3859")
    @from = store.postal_code
    @header = headers
  end

  private

  def encode_credentials(public_key, private_key)
    Base64.strict_encode64("#{public_key}:#{private_key}")
  end

  def headers
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
end
