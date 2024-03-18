# frozen_string_literal: true

module EndiServices
  class UploadToCloudinary
    include ApplicationHelper

    def initialize(order, user)
      @order = order
      @user = user
      @url = "#{Rails.application.credentials.endi.public_send(Rails.env).endi_path}/invoices/#{@order.endi_id}.pdf"
    end

    def call
      tempfile = Tempfile.new("asset")

      URI.open(@url, "Cookie" => @user.endi_auth) do |f|
        File.binwrite(tempfile.path, f.read)
      end

      @order.bill.attach(io: tempfile, filename: "nes.png", content_type: "image/png")
    end
  end
end
