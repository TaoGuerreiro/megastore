# frozen_string_literal: true

module Shipments
  class Parcel < Shipment
    include ActiveModel::Model

    attr_accessor :store, :order, :items, :user, :shipping

    def initialize(store, param)
      super(store)
      @store = store
      @order = param[:order]
      @items = @order.items
      @user = @order.user
      @shipping = @order.shipping
    end

    def create_label
      update_shipping_status("processing")

      response = create_label_request
      update_shipping_details(response) unless @order.shipping.method_carrier == "poste"

      update_shipping_status("processed")
      response
    rescue StandardError => e
      handle_error(e)
    end

    private

    def update_shipping_status(status)
      @shipping.update(api_error: nil, status:)
    end

    def create_label_request
      case @order.shipping.method_carrier
      when "poste" then postale_label
      else
        url = "#{BASE_URL}/parcels?errors=verbose-carrier"
        response = HTTParty.post(url, headers:, body: body.to_json)
        response.parsed_response
      end
    end

    def update_shipping_details(response)
      parcel = response["parcel"]
      @order.shipping.update(
        parcel_id: parcel["id"],
        api_tracking_number: parcel["tracking_number"],
        api_tracking_url: parcel["tracking_url"],
        api_method_name: parcel["shipment"]["name"]
      )
    end

    def handle_error(error)
      @order.shipping.update(api_error: error.to_s, status: "failed")
    end

    def body
      {
        parcel: {
          shipment: {
            id: @order.shipping.api_shipping_id,
            name: @order.shipping.method_carrier
          },
          weight: @order.shipping.weight.to_i.fdiv(1000).to_s,
          height: "50",
          width: "50",
          length: "50",
          order_number: @order.id,
          shipping_method_checkout_name: "Stripe",
          to_service_point: @order.shipping.api_service_point_id
        }.
          merge(from).
          merge(infos)
      }
    end

    # rubocop:disable Naming/VariableNumber
    def infos
      {
        name: @order.shipping.full_name,
        address: @order.shipping.address_first_line,
        address_2: @order.shipping.address_second_line,
        city: @order.shipping.city,
        postal_code: @order.shipping.postal_code,
        country: @order.shipping.country,
        telephone: @user.phone,
        request_label: true,
        email: @user.email
      }
    end

    def from
      {
        from_name: @store.name,
        from_company_name: @store.name,
        from_address_1: @store.address,
        from_city: @store.city,
        from_postal_code: @store.postal_code,
        from_country: @store.country,
        from_telephone: @store.admin.phone,
        from_email: @store.admin.email
      }
    end
    # rubocop:enable Naming/VariableNumber

    # POSTALE SERVICES

    def postale_headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{postale_token}",
        "Accept-Encoding" => "gzip"
      }
    end

    # rubocop:disable Metrics/AbcSize
    def postale_body
      {
        order: {
          custPurchaseOrderNumber: @order.id,
          invoicing: {
            contractNumber: Rails.application.credentials.postale.send("#{Rails.env}").contract_number,
            custAccNumber: "46",
            custInvoice: "46"
          },
          offer: {
            masterOutputOptions: {
              firstVignettePosition: 1,
              visualFormatCode: "rollA"
            },
            offerCode: "3125",
            products: [
              {
                productCode: "K7",
                productOptions: {
                  clientReference: {
                    cref1: "AK",
                    cref2: "FX187VA"
                  },
                  deliveryTrackingFlag: true,
                  weight: @order.shipping.weight.to_i
                },
                receiver: {
                  address: {
                    name1: @order.shipping.full_name,
                    add2: "",
                    add4: @order.shipping.street,
                    zipcode: @order.shipping.postal_code,
                    town: @order.shipping.city,
                    countryCode: "250"
                  },
                  email: @user.email,
                  phone: @user.phone
                },
                sender: {
                  address: {
                    name1: @store.name,
                    add4: @store.address,
                    zipcode: @store.postal_code,
                    town: @store.city,
                    countryCode: "250"
                  },
                  email: @store.admin.email,
                  phone: @store.admin.phone
                }
              }
            ]
          }
        }
      }
    end
    # rubocop:enable Metrics/AbcSize

    def postale_label
      url = Rails.application.credentials.postale.send("#{Rails.env}").postage_url

      response = HTTParty.post(url, body: postale_body.to_json, headers: postale_headers)

      base_64_label = response["order"]["offer"]["visualOutput"]

      attach_to_order(base_64_label)
    end

    def attach_to_order(base_64_label)
      tempfile = Tempfile.new(["label", ".png"])

      File.binwrite(tempfile.path, Base64.decode64(base_64_label))

      @order.label.attach(io: tempfile, filename: "label.png", content_type: "image/png")
    end

    def postale_token
      url = Rails.application.credentials.postale.send("#{Rails.env}").token_url

      headers = {
        "Content-Type" => "application/x-www-form-urlencoded"
      }
      body = {
        grant_type: "client_credentials",
        client_id: Rails.application.credentials.postale.send("#{Rails.env}").client_id,
        client_secret: Rails.application.credentials.postale.send("#{Rails.env}").client_secret
      }
      response = HTTParty.post(url, body:, headers:)
      response["access_token"]
    end
  end
end
