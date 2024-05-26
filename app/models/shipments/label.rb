# frozen_string_literal: true

module Shipments
  class Label < Shipment
    include ActiveModel::Model

    def initialize(store, param)
      super(store)
      @store = store
      @order = param[:order]
    end

    def download_pdf
      url = "#{BASE_URL}/labels/normal_printer/#{@order.shipping.parcel_id}"
      HTTParty.post(url, headers:)
    end

    def attach_to_order
      return true if @order.shipping.method_carrier == "poste"

      @order.label.attach(io: tempfile, filename: "label.pdf", content_type: "image/png")
    end

    private

    def tempfile
      url = URI("#{BASE_URL}/labels/normal_printer/#{@order.shipping.parcel_id}")
      temporary_file = Tempfile.new(["label", ".pdf"])

      Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
        request = Net::HTTP::Get.new(url, headers)
        response = http.request(request)

        File.binwrite(temporary_file.path, response.body)
      end
    end

    def headers
      {
        "Accept" => "application/pdf",
        "Authorization" => "Basic #{@token}"
      }
    end
  end
end
