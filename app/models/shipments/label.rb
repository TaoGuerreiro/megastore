# frozen_string_literal: true

module Shipments
  class Label < BaseShipment
    attr_accessor :order

    def initialize(store, param)
      super(store)
      @order = param[:order]
    end

    def download_pdf
      url = "#{BASE_URL}/labels/normal_printer/#{@order.shipping.parcel_id}"
      response = HTTParty.get(url, headers: sendcloud_headers)
      handle_api_response(response, context: "Label download")
    end

    def attach_to_order
      return true if @order.shipping.method_carrier == "poste"

      @order.label.attach(io: tempfile, filename: "label.pdf", content_type: "image/png")
    end

    private

    def tempfile
      url = URI("#{BASE_URL}/labels/normal_printer/#{@order.shipping.parcel_id}")
      @temporary_file = Tempfile.new(["label", ".png"])

      Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
        request = Net::HTTP::Get.new(url, label_headers)
        response = http.request(request)

        File.binwrite(@temporary_file.path, response.body)
      end
      @temporary_file
    end

    def label_headers
      {
        "Accept" => "application/pdf",
        "Authorization" => "Basic #{@token}"
      }
    end
  end
end
