require 'rails_helper'

RSpec.describe "StripeEvents", type: :request do

  before(:all) do
    @store = create(:store, :with_items)
    Current.store = @store
  end

  describe "customer events" do
    it "will return a 200 if successful" do

      VCR.use_cassette("find_shipping_method") do
        @response = Shipments::ShippingMethod.new(@store,
                                      {
                                        country: "FR",
                                        postal_code: "44000"
                                      }).find(1345)
      end
      VCR.eject_cassette

      expect(@response[:name]).to eq("Chrono 18 0-2kg")
    end
  end
end
