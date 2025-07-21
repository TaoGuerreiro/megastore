require 'rails_helper'

RSpec.describe "Services d'expédition (SendCloud)", type: :request do
  before(:all) do
    @store = create(:store, :with_items)
    Current.store = @store
    @order = create(:order, store: @store)
  end

  describe "création de colis" do
    it "retourne 'Chrono 18 0-2kg' si succès" do
      VCR.use_cassette("create_parcel") do
        @response = Shipments::Parcel.new(@store, { order: @order }).create_label
      end
      VCR.eject_cassette
      expect(@response["parcel"]["shipment"]["name"]).to eq("Chrono 18 0-2kg")
    end
  end

  describe "recherche de méthode de livraison" do
    it "retourne 'Chrono 18 0-2kg' si succès" do
      VCR.use_cassette("find_shipping_method_v2") do
        @response = Shipments::ShippingMethod.new(@store, { country: "FR", postal_code: "44000" }).find(1345)
      end
      VCR.eject_cassette
      expect(@response[:name]).to eq("Chrono 18 0-2kg")
    end
  end

  describe "téléchargement du PDF du label" do
    it "retourne un PDF commençant par %PDF si succès" do
      VCR.use_cassette("download_label") do
        @response = Shipments::Label.new(@store, { order: @order }).download_pdf
      end
      VCR.eject_cassette
      expect(@response).to be_a(String)
      expect(@response).to start_with("%PDF")
    end
  end
end
