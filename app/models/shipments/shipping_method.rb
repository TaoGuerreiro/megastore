# frozen_string_literal: true

module Shipments
  class ShippingMethod < Shipment
    def initialize(store, param)
      super(store)
      @country = param[:country]
      @postal_code = param[:postal_code]
      @weight = param[:weight] # in gramme
      @height = param[:height] # in mm
      @url_params = "?from_postal_code=#{@from}&to_postal_code=#{@postal_code}&to_country=#{@country}"
    end

    def all
      response = fetch_shipping_methods
      filter_and_group_shipping_methods(response["shipping_methods"]).map do |method|
        transform_method(method)
      end
    end

    def find(id)
      response = fetch_shipping_method(id)
      transform_method(response["shipping_method"])
    end

    private

    def filter_params
      {
        mondial_relay: { service_point_input: true, home_input: false },
        chronopost: { service_point_input: false, home_input: true },
        colissimo: { service_point_input: false, home_input: true },
        colisprive: { service_point_input: true, home_input: false },
        sendcloud: { service_point_input: false, home_input: false }
      }
    end

    def fetch_shipping_methods
      url = "#{BASE_URL}/shipping_methods" + @url_params
      HTTParty.get(url, headers:)
    end

    def fetch_shipping_method(id)
      url = "#{BASE_URL}/shipping_methods/#{id}" + @url_params
      HTTParty.get(url, headers:)
    end

    def filter_and_group_shipping_methods(methods)
      filtered_methods = filter_methods_by_weight(methods)
      required_filtered = filtered_methods.select do |method|
        (filter_params[method["carrier"].to_sym][:service_point_input] == true &&
         method["service_point_input"] == "required") ||
          (filter_params[method["carrier"].to_sym][:home_input] == true &&
           method["service_point_input"] == "none")
      end
      group_methods_by_carrier(required_filtered)
    end

    def filter_methods_by_weight(methods)
      methods.select { |method| method["min_weight"].to_f <= @weight && method["max_weight"].to_f >= @weight }
    end

    def group_methods_by_carrier(methods)
      methods.group_by { |method| method["carrier"] }.map do |_carrier, sub_methods|
        sub_methods.min_by { |method| method["countries"][0]["price"] }
      end
    end

    def transform_method(method)
      {
        id: method["id"],
        name: method["name"],
        carrier: method["carrier"],
        min_weight: method["min_weight"],
        max_weight: method["max_weight"],
        service_point_input: method["service_point_input"],
        price: method["countries"][0]["price"],
        lead_time_hours: method["countries"][0]["lead_time_hours"]
      }
    end
  end
end
