# frozen_string_literal: true

module Shipments
  class PostaleService
    include ActiveModel::Model

    attr_accessor :store, :order, :user

    def initialize(store:, order:, user:)
      @store = store
      @order = order
      @user = user
    end

    def create_label
      log_operation("create_postale_label")

      response = HTTParty.post(
        postale_credentials.postage_url,
        body: build_order_body.to_json,
        headers: postale_headers(postale_token)
      )

      handle_api_response(response, context: "Postale label creation")
    end

    def find_shipping_method(weight)
      postage_data.find do |postage|
        postage[:min_weight] <= weight && weight <= postage[:max_weight]
      end
    end

    def find_service_by_id(id)
      postage = postage_data.find { |method| method[:id] == id }
      { "shipping_method" => postage } if postage
    end

    private

    def build_order_body
      {
        order: {
          custPurchaseOrderNumber: @order.id,
          invoicing: build_invoicing,
          offer: build_offer
        }
      }
    end

    def build_invoicing
      {
        contractNumber: postale_credentials.contract_number,
        custAccNumber: "671775",
        custInvoice: "46"
      }
    end

    def build_offer
      {
        masterOutputOptions: {
          firstVignettePosition: 1,
          visualFormatCode: "rollA"
        },
        offerCode: "3125",
        products: [build_product]
      }
    end

    def build_product
      {
        productCode: "K7",
        productOptions: build_product_options,
        receiver: build_receiver,
        sender: build_sender
      }
    end

    def build_product_options
      {
        clientReference: {
          cref1: "AK",
          cref2: "FX187VA"
        },
        deliveryTrackingFlag: true,
        weight: @order.shipping.weight.to_i
      }
    end

    def build_receiver
      {
        address: build_receiver_address,
        email: @user.email,
        phone: @user.phone
      }
    end

    def build_receiver_address
      {
        name1: @order.shipping.full_name,
        add2: "",
        add4: @order.shipping.street[0...38],
        zipcode: @order.shipping.postal_code,
        town: @order.shipping.city,
        countryCode: "250"
      }
    end

    def build_sender
      {
        address: build_sender_address,
        email: @store.admin.email,
        phone: @store.admin.phone
      }
    end

    def build_sender_address
      {
        name1: @store.name,
        add4: @store.address,
        zipcode: @store.postal_code,
        town: @store.city,
        countryCode: "250"
      }
    end

    def postale_credentials
      Rails.application.credentials.postale.send(Rails.env.to_s)
    end

    def postale_headers(token)
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{token}",
        "Accept-Encoding" => "gzip"
      }
    end

    def postale_auth_headers
      {
        "Content-Type" => "application/x-www-form-urlencoded"
      }
    end

    def postale_token
      @postale_token ||= fetch_postale_token
    end

    def fetch_postale_token
      url = postale_credentials.token_url
      body = {
        grant_type: "client_credentials",
        client_id: postale_credentials.client_id,
        client_secret: postale_credentials.client_secret
      }

      response = HTTParty.post(url, body:, headers: postale_auth_headers)
      handle_api_response(response, context: "Postale token")["access_token"]
    end

    def postage_data
      @postage_data ||= load_postage_data
    end

    def load_postage_data
      file_path = Rails.root.join("lib/poste.json")
      JSON.parse(File.read(file_path), symbolize_names: true)
    end

    def handle_api_response(response, context: "API call")
      return response.parsed_response if response.success?

      error_message = "API Error (#{context}): #{response.code} - #{response.body}"
      Rails.logger.error(error_message)
      raise ShipmentError, error_message
    end

    def log_operation(operation)
      Rails.logger.info(
        "Postale #{operation}",
        store_id: @store.id,
        order_id: @order.id
      )
    end
  end
end
