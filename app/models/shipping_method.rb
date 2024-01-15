class ShippingMethod
  include ActiveModel::Model
  BASE_URL = "https://panel.sendcloud.sc/api/v2"

  def initialize(store, params)
    @params = params
    @token = encode_credentials(store.sendcloud_public_key, store.sendcloud_private_key)
    @from = store.postal_code
    @weight = params[:weight] || 0.5
    @url = "#{BASE_URL}/shipping_methods?from_postal_code=#{@from}&to_postal_code=#{params[:to_postal_code]}&to_country=#{params[:to_country]}"
  end

  def all
    raise
    response = HTTParty.get(@url, headers: headers)
    filter_and_group_shipping_methods(response["shipping_methods"])
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
