# frozen_string_literal: true

class Shipment
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
      update_shipping_details(response)

      update_shipping_status("processed")
    rescue StandardError => e
      handle_error(e)
    end

    private

    def update_shipping_status(status)
      @shipping.update(api_error: nil, status:)
    end

    def create_label_request
      url = "#{BASE_URL}/parcels?errors=verbose-carrier"
      response = HTTParty.post(url, headers: {}, body: body.to_json)
      response.parsed_response
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
  end
end
