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
      @carriers = filter_and_group_shipping_methods(response["shipping_methods"]).map do |method|
        transform_method(method)
      end

      add_poste_to_carriers if @country == "FR" && @height < 30
      @carriers
    end

    def find(id)
      response = fetch_shipping_method(id)
      transform_method(response["shipping_method"])
    end

    private

    def add_poste_to_carriers
      @carriers << postale_carrier
    end

    def postale_carrier
      file_path = Rails.root.join("lib/poste.json")
      postage_data = JSON.parse(File.read(file_path), symbolize_names: true)

      postage_data.find do |postage|
        postage[:min_weight] <= @weight && @weight <= postage[:max_weight]
      end
    end

    def postale_service(id)
      file_path = Rails.root.join("lib/poste.json")
      postage_data = JSON.parse(File.read(file_path), symbolize_names: true)
      postage = postage_data.find { |method| method[:id] == id }
      { "shipping_method" => postage } if postage
    end

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
      return postale_service(id) if id[0] == "P"

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
      methods.select do |method|
        method["min_weight"].to_f <= @weight.fdiv(1000) && method["max_weight"].to_f >= @weight.fdiv(1000)
      end
    end

    def group_methods_by_carrier(methods)
      methods.group_by { |method| method["carrier"] }.map do |_carrier, sub_methods|
        sub_methods.min_by { |method| method["countries"][0]["price"] }
      end
    end

    # rubocop:disable  Metrics/AbcSize
    def transform_method(method)
      if method[:id] && method[:id][0] == "P"
        return {
          id: method[:id],
          name: method[:name],
          carrier: method[:carrier],
          min_weight: method[:min_weight],
          max_weight: method[:max_weight],
          service_point_input: false,
          price: method[:price],
          lead_time_hours: method[:lead_time_hour]
        }
      end
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
    # rubocop:enable  Metrics/AbcSize
  end
end
