class Carrier
  include ActiveModel::Model
  BASE_URL = "https://panel.sendcloud.sc/api/v2"

  def initialize(store, params)
    @params = params
    @token = encode_credentials(store.sendcloud_public_key, store.sendcloud_private_key)
    @from = store.postal_code
    @weight = params[:weight].fdiv(1000) || 0.5
    @url = "#{BASE_URL}/shipping_methods?from_postal_code=#{@from}&to_postal_code=#{params["postal_code"]}&to_country=#{params["country"]}"
  end

  def all
    response = HTTParty.get(@url, headers: headers)
    filter_and_group_shipping_methods(response["shipping_methods"]).map do |method|
      ShippingMethod.new({
        shipping_method_api_id: method["id"],
        name: method["name"],
        carrier: method["carrier"],
        min_weight: method["min_weight"],
        max_weight: method["max_weight"],
        service_point_input: method["service_point_input"],
        price: method["countries"][0]["price"],
        lead_time_hours: method["countries"][0]["lead_time_hours"]
      })
    end
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

  def filter_and_group_shipping_methods(methods)
    filtered_methods = filter_methods_by_weight(methods)
    group_methods_by_carrier(filtered_methods)
  end

  def filter_methods_by_weight(methods)
    methods.select { |method| method["min_weight"].to_f <= @weight && method["max_weight"].to_f >= @weight }
  end

  def group_methods_by_carrier(methods)
    methods.group_by { |method| method["carrier"] }.map { |carrier, methods| methods.min_by { |method| method["countries"][0]["price"] } }
  end
end
