# frozen_string_literal: true

require "rails_helper"

RSpec.describe Shipments::BaseShipment, type: :model do
  let(:store) { create(:store) }
  let(:base_shipment) { described_class.new(store) }

  describe "#initialize" do
    it "initialise le store et les credentials" do
      expect(base_shipment.store).to eq(store)
      expect(base_shipment.from).to eq(store.postal_code)
    end
  end

  describe "#sendcloud_headers" do
    it "retourne les bons headers pour l'API Sendcloud" do
      headers = base_shipment.send(:sendcloud_headers)
      expect(headers["Content-Type"]).to eq("application/json")
      expect(headers["Accept"]).to eq("application/json")
      expect(headers["Authorization"]).to start_with("Basic ")
    end
  end

  describe "#points_headers" do
    it "retourne les bons headers pour l'API des points relais" do
      headers = base_shipment.send(:points_headers)
      expect(headers["Content-Type"]).to eq("application/json")
      expect(headers["Accept"]).to eq("application/json")
      expect(headers["Authorization"]).to start_with("Basic ")
    end
  end

  describe "#handle_api_response" do
    context "quand la réponse est un succès" do
      let(:response) { double("response", success?: true, parsed_response: { "data" => "test" }) }
      it "retourne la réponse parsée" do
        result = base_shipment.send(:handle_api_response, response)
        expect(result).to eq({ "data" => "test" })
      end
    end
    context "quand la réponse est un échec" do
      let(:response) { double("response", success?: false, code: 400, body: "Bad Request") }
      it "lève une ShipmentError" do
        expect {
          base_shipment.send(:handle_api_response, response, context: "test")
        }.to raise_error(Shipments::ShipmentError, /API Error \(test\): 400 - Bad Request/)
      end
    end
  end

  describe "#validate_required_params" do
    it "ne lève pas d'erreur si tous les paramètres sont présents" do
      params = { nom: "test", email: "test@example.com" }
      expect {
        base_shipment.send(:validate_required_params, params, [:nom, :email])
      }.not_to raise_error
    end
    it "lève une erreur si un paramètre est manquant" do
      params = { nom: "test" }
      expect {
        base_shipment.send(:validate_required_params, params, [:nom, :email])
      }.to raise_error(ArgumentError, "Missing required parameters: email")
    end
  end

  describe "#log_operation" do
    it "log l'opération avec les détails" do
      expect(Rails.logger).to receive(:info).with(
        hash_including(
          operation: "Shipment test_operation",
          store_id: store.id,
          details: { test: "data" }
        )
      )
      base_shipment.send(:log_operation, "test_operation", test: "data")
    end
  end
end
