# frozen_string_literal: true

class Shipment
  class ServicePoint < Shipment
    include ActiveModel::Model

    attr_accessor :country, :postal_code, :radius, :carrier

    def initialize(store, param)
      super(store)
      @country = param[:country]
      @postal_code = param[:postal_code]
      @radius = param[:radius]
      @carrier = param[:carrier]
      @url_params = "?country=#{@country}&address=#{@postal_code}&radius=#{@radius}&carrier=#{@carrier}"
    end

    def all
      fetch_service_points.map.with_index do |service_point, index|
        format_service_point(service_point, index)
      end
    end

    private

    def fetch_service_points
      url = "#{SERVICE_POINT_BASE_URL}/service-points" + @url_params
      response = HTTParty.get(url, headers:)
      response.parsed_response
    end

    def format_service_point(service_point, index)
      {
        index: index + 1,
        id: service_point["id"],
        name: service_point["name"],
        street: service_point["street"],
        house_number: service_point["house_number"],
        postal_code: service_point["postal_code"],
        city: service_point["city"],
        country: service_point["country"],
        longitude: service_point["longitude"].to_f,
        latitude: service_point["latitude"].to_f,
        distance: service_point["distance"],
        info_window_html: render_info_window(service_point)
      }
    end

    def render_info_window(service_point)
      ac = ActionController::Base.new
      ac.render_to_string(partial: "checkouts/info_window", locals: { service_point: })
    end
  end
end
