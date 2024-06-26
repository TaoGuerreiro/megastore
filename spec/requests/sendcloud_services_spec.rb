require 'rails_helper'

RSpec.describe "SendCloud Services", type: :request do

  before(:all) do
    @store = create(:store, :with_items)
    Current.store = @store
    @order = create(:order, store: @store)
  end

  describe "creating parcel" do
    it "will return 'Chrono 18 0-2kg' if successful" do

      VCR.use_cassette("create_parcel") do
        @response = Shipments::Parcel.new(@store,
                                      {
                                        order: @order
                                      }).create_label
      end
      VCR.eject_cassette
      expect(@response["parcel"]["shipment"]["name"]).to eq("Chrono 18 0-2kg")
    end
  end

  describe "customer events" do
    it "will return 'Chrono 18 0-2kg' if successful" do

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

  describe "download pdf label" do
    it "will return a 200 if successful" do

      VCR.use_cassette("download_label") do
        @response = Shipments::Label.new(@store,
                                      {
                                        order: @order
                                      }).download_pdf
      end
      VCR.eject_cassette

      expect(@response.code).to eq(200)
      expect(@response).to be_an_instance_of(HTTParty::Response)
    end
  end
end
