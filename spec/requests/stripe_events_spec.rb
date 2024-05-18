# require 'rails_helper'

# RSpec.describe "StripeEvents", type: :request do

#   def bypass_event_signature(payload)
#     @event = Stripe::Event.construct_from(JSON.parse(payload, symbolize_names: true))
#     expect(Stripe::Webhook).to receive(:construct_event).and_return(@event)
#   end

#   before(:all) do
#     VCR.use_cassette("stripe_create_customer") do
#       Stripe::Customer.create({name: "Tester One", description: "Test customer", email: "test@testers.com"})
#     end
#     VCR.eject_cassette
#   end

#   describe "customer events" do
#     it "will return a 200 if successful" do
#       @request_body = StripeHelpers.construct_webhook_response("stripe_create_customer", "customer.created")
#       bypass_event_signature(@request_body.to_json)
#       post("http://www.example.com/webhooks/stripe", params: @request_body.to_json)
#       expect(response).to have_http_status(:success)
#     end
#   end
# end
