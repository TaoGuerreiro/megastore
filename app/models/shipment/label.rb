# frozen_string_literal: true

class Shipment
  class Label < Shipment
    include ActiveModel::Model

    def initialize(store, param)
      super(store)
      @store = store
      @order = param[:order]
    end

    def download_pdf
      url = "#{BASE_URL}/labels/normal_printer/#{@order.parcel_id}"
      response = HTTParty.post(url, headers:)
    end

    def attach_to_order
      url = "#{BASE_URL}/labels/normal_printer/#{@order.parcel_id}"
      tempfile = Tempfile.new('asset')

      URI.open(url, headers) do |f|
        File.binwrite(tempfile.path, f.read)
      end

      @order.label.attach(io: tempfile, filename: 'label.png', content_type: 'image/png')
    end

    private

    def headers
      {
        'Accept' => 'application/pdf',
        'Authorization' => "Basic #{@token}"
      }
    end
  end
end
