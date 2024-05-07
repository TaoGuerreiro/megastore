# frozen_string_literal: true

class EndiServices
  class UploadToCloudinary < EndiServices
    include ApplicationHelper

    def initialize(order)
      super()
      @order = order
      @url = "#{ENDI_PATH}/invoices/#{order.endi_id}.pdf"
    end

    def call
      tempfile = Tempfile.new("asset")

      Net::HTTP.start(@url.host, @url.port, use_ssl: true) do |http|
        request = Net::HTTP::Get.new(@url)
        request["Cookie"] = Current.endi_auth
        response = http.request(request)
        File.binwrite(tempfile.path, response.body)
      end

      @order.bill.attach(io: tempfile, filename: "nes.png", content_type: "image/png")
    end
  end
end
