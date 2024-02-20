# frozen_string_literal: true

class Shipment
  class ShippingMethod < Shipment
    def initialize(store, param)
      super(store)
      @store = store
      @country = param[:country]
      @postal_code = param[:postal_code]
      @weight = param[:weight]&.fdiv(1000) # en gramme
    end

    def all
      url = "#{BASE_URL}/shipping_methods?from_postal_code=#{@from}&to_postal_code=#{@postal_code}&to_country=#{@country}"
      response = HTTParty.get(url, headers:)
      filter_params = {
        mondial_relay: { service_point_input: true, home_input: false },
        chronopost: { service_point_input: false, home_input: true },
        colissimo: { service_point_input: false, home_input: true },
        colisprive: { service_point_input: true, home_input: false },
        sendcloud: { service_point_input: false, home_input: false }
      }
      filter_and_group_shipping_methods(response['shipping_methods'], filter_params).map do |method|
        {
          id: method['id'],
          name: method['name'],
          carrier: method['carrier'],
          min_weight: method['min_weight'],
          max_weight: method['max_weight'],
          service_point_input: method['service_point_input'],
          price: method['countries'][0]['price'],
          lead_time_hours: method['countries'][0]['lead_time_hours']
        }
      end
    end

    def find(id)
      url = "#{BASE_URL}/shipping_methods/#{id}?from_postal_code=#{@from}&to_postal_code=#{@postal_code}&to_country=#{@country}"
      response = HTTParty.get(url, headers:)
      shipping_method = response['shipping_method']
      {
        id: shipping_method['id'],
        name: shipping_method['name'],
        carrier: shipping_method['carrier'],
        min_weight: shipping_method['min_weight'],
        max_weight: shipping_method['max_weight'],
        service_point_input: shipping_method['service_point_input'],
        price: shipping_method['countries'][0]['price'],
        lead_time_hours: shipping_method['countries'][0]['lead_time_hours']
      }
    end

    private

    def filter_and_group_shipping_methods(methods, filter_params)
      filtered_methods = filter_methods_by_weight(methods)
      required_filterd = filtered_methods.select do |method|
        filter_params[method['carrier'].to_sym][:service_point_input] == true && method['service_point_input'] == 'required' ||
          filter_params[method['carrier'].to_sym][:home_input] == true && method['service_point_input'] == 'none'
      end
      group_methods_by_carrier(required_filterd)
    end

    def filter_methods_by_weight(methods)
      methods.select { |method| method['min_weight'].to_f <= @weight && method['max_weight'].to_f >= @weight }
    end

    def group_methods_by_carrier(methods)
      methods.group_by { |method| method['carrier'] }.map do |_carrier, methods|
        methods.min_by do |method|
          method['countries'][0]['price']
        end
      end
    end
  end
end

# {"id"=>4768,
#  "name"=>"Colis Privé Point Relais 19-20kg",
#  "carrier"=>"colisprive",
#  "min_weight"=>"19.001",
#  "max_weight"=>"20.001",
#  "service_point_input"=>"required",
#  "price"=>0,
#  "countries"=>[{"id"=>8,
#  "name"=>"France",
#  "price"=>14.72,
#  "iso_2"=>"FR",
#  "iso_3"=>"FRA",
#  "lead_time_hours"=>48,
#  "price_breakdown"=>[{"type"=>"price_without_insurance",
#  "label"=>"Label",
#  "value"=>13.95},
#  {"type"=>"fuel",
#  "label"=>"Fuel surcharge (5.50%)",
#  "value"=>0.77}]}]}
