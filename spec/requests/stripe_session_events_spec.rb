# require 'rails_helper'

# RSpec.describe "StripeEvents", type: :request do

#   def bypass_event_signature(payload)
#     @event = Stripe::Event.construct_from(JSON.parse(payload, symbolize_names: true))
#     # expect(Stripe::Webhook).to receive(:construct_event).and_return(@event)
#   end

#   before(:all) do
#     Current.store = create(:store, :with_items)
#     line_items = [
#       {
#         price_data: {
#           currency: "eur",
#           unit_amount: 666,
#           product_data: {
#             name: "Name test",
#             description: "Description test",
#             images: nil
#           }
#         },
#         quantity: 1
#       }
#     ]
#     VCR.use_cassette("stripe_checkout_session") do
#       Stripe::Checkout::Session.create(
#         {
#           mode: "payment",
#           customer_email: "mail@mail.fr",
#           line_items: line_items,
#           payment_intent_data: {
#             application_fee_amount: 666
#           },
#           success_url: order_url(1),
#           cancel_url: order_url(1)
#         },
#         {
#           stripe_account: Current.store.stripe_account_id
#         }
#       )
#     end

#     VCR.eject_cassette
#   end

#   describe "customer events" do
#     it "will return a 200 if successful" do
#       @request_body = StripeHelpers.construct_webhook_response("stripe_checkout_session", "checkout.session.completed")
#       bypass_event_signature(@request_body.to_json)
#       post("/webhooks/stripe", params: @request_body)
#       expect(response).to have_http_status(:success)
#     end
#   end
# end
