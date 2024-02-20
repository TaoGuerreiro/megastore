# frozen_string_literal: true

class Shipment
  class ServicePoint < Shipment
    include ActiveModel::Model

    def initialize(store, param)
      super(store)
      @store = store
      @country = param[:country]
      @postal_code = param[:postal_code]
      @radius = param[:radius]
      @carrier = param[:carrier]
    end

    def all
      # {{servicePointsBaseUrl}}/service-points?country=FR&address=44000&radius=100
      url = "#{SERVICE_POINT_BASE_URL}/service-points?country=#{@country}&address=#{@postal_code}&radius=#{@radius}&carrier=#{@carrier}"
      response = HTTParty.get(url, headers:)
      ac = ActionController::Base.new

      response.map.with_index do |service_point, index|
        {
          index: index + 1,
          id: service_point['id'],
          name: service_point['name'],
          street: service_point['street'],
          house_number: service_point['house_number'],
          postal_code: service_point['postal_code'],
          city: service_point['city'],
          country: service_point['country'],
          longitude: service_point['longitude'].to_f,
          latitude: service_point['latitude'].to_f,
          distance: service_point['distance'],
          info_window_html: ac.render_to_string(partial: 'checkouts/info_window',
                                                locals: { service_point: })
        }
      end
    end
  end
end
