# frozen_string_literal: true

# {
#   "parcel": {
#     "name": "<string>",
#     "address": "<string>",
#     "city": "<string>",
#     "postal_code": "<string>",
#     "country": "<string>",
#     "id": "<integer>",
#     "company_name": "<string>",
#     "contract": "<integer>",
#     "address_2": "<string>",
#     "house_number": "<string>",
#     "telephone": "<string>",
#     "request_label": "<boolean>",
#     "email": "<string>",
#     "data": {},
#     "shipment": {
#       "id": "<integer>",
#       "name": "<string>"
#     },
#     "weight": "<string>",
#     "order_number": "<string>",
#     "insured_value": "<integer>",
#     "total_order_value_currency": "<string>",
#     "total_order_value": "<string>",
#     "quantity": "<integer>",
#     "shipping_method_checkout_name": "<string>",
#     "to_post_number": "<string>",
#     "country_state": "<string>",
#     "sender_address": "<integer>",
#     "customs_invoice_nr": "<string>",
#     "customs_shipment_type": 0,
#     "external_reference": "<string>",
#     "to_service_point": "<integer>",
#     "total_insured_value": "<integer>",
#     "shipment_uuid": "<string>",
#     "parcel_items": [
#       {
#         "hs_code": "<string>",
#         "weight": "<string>",
#         "quantity": "<integer>",
#         "description": "<string>",
#         "value": "<number>",
#         "origin_country": "<string>",
#         "sku": "<string>",
#         "product_id": "<string>",
#         "properties": {},
#         "item_id": "<string>",
#         "return_reason": "<integer>",
#         "return_message": "<string>"
#       },
#       {
#         "hs_code": "<string>",
#         "weight": "<string>",
#         "quantity": "<integer>",
#         "description": "<string>",
#         "value": "<number>",
#         "origin_country": "<string>",
#         "sku": "<string>",
#         "product_id": "<string>",
#         "properties": {},
#         "item_id": "<string>",
#         "return_reason": "<integer>",
#         "return_message": "<string>"
#       }
#     ],
#     "is_return": "<boolean>",
#     "length": "<string>",
#     "width": "<string>",
#     "height": "<string>",
#     "request_label_async": "<boolean>",
#     "apply_shipping_rules": "<boolean>",
#     "from_name": "<string>",
#     "from_company_name": "<string>",
#     "from_address_1": "<string>",
#     "from_address_2": "<string>",
#     "from_house_number": "<string>",
#     "from_city": "<string>",
#     "from_postal_code": "<string>",
#     "from_country": "<string>",
#     "from_telephone": "<string>",
#     "from_email": "<string>",
#     "from_vat_number": "<string>",
#     "from_eori_number": "<string>",
#     "from_inbound_vat_number": "<string>",
#     "from_inbound_eori_number": "<string>",
#     "from_ioss_number": "<string>"
#   }
# }

class Shipment
  class Parcel < Shipment
    include ActiveModel::Model

    def initialize(store, param)
      super(store)
      @store = store
      @order = param[:order]
      @items = @order.items
      @user = @order.user
    end

    def create_label
      url = "#{BASE_URL}/parcels?errors=verbose-carrier"
      response = HTTParty.post(url, headers:, body: body.to_json)
      response.parsed_response
      @order.shipping.update(
        parcel_id: response['parcel']['id'],
        api_tracking_number: response['parcel']['tracking_number'],
        api_tracking_url: response['parcel']['tracking_url'],
        api_method_name: response['parcel']['shipment']['name']
      )
    end

    def body
      {
        "parcel": {
          "name": @order.shipping.full_name,
          "address": @order.shipping.address,
          "city": @order.shipping.city,
          "postal_code": @order.shipping.postal_code,
          "country": @order.shipping.country,
          "telephone": @user.phone,
          "request_label": true,
          "email": @user.email,
          "shipment": {
            "id": @order.shipping.api_shipping_id,
            "name": @order.shipping.method_carrier
          },
          "weight": @order.shipping.weight.to_i.fdiv(1000).to_s,
          "height": '50',
          "width": '50',
          "length": '50',
          "order_number": @order.id,
          "shipping_method_checkout_name": 'Stripe',
          "to_service_point": @order.shipping.api_service_point_id,
          "from_name": @store.name,
          "from_company_name": @store.name,
          "from_address_1": @store.address,
          "from_city": @store.city,
          "from_postal_code": @store.postal_code,
          "from_country": @store.country,
          "from_telephone": @store.admin.phone,
          "from_email": @store.admin.email
        }
      }
    end
  end
end

# {
#   "parcel": {
#     "name": "Le Cheveu Blanc",
#     "address": "26 bis rue aristide briand",
#     "city": "saint sébastien sur loire",
#     "postal_code": "44230",
#     "country": "FR",
#     "telephone": null,
#     "request_label": "u003cbooleanu003e",
#     "email": "florent.guilbaud@gmail.com",
#     "data": {},
#     "shipment":
#       {
#         "id": 4745,
#         "name": "colisprive"
#       },
#     "weight": "56",
#     "order_number": 13,
#     "shipping_method_checkout_name": "Stripe",
#     "sender_address": ",  , ",
#     "to_service_point": 11181183,
#     "from_name": "Le Cheveu Blanc",
#     "from_company_name": "Le Cheveu Blanc",
#     "from_address_1": "",
#     "from_city": "",
#     "from_postal_code": "",
#     "from_country": "",
#     "from_telephone": null,
#     "from_email": null}}
