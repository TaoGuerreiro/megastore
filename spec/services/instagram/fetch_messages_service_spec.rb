# frozen_string_literal: true

require "rails_helper"

RSpec.describe Instagram::FetchMessagesService do
  let(:username) { "test_user" }
  let(:password) { "test_password" }
  let(:recipient_id) { "123456789" }
  let(:hours_back) { 24 }

  describe ".call" do
    let(:temp_file) { instance_double(Tempfile) }

    before do
      allow(Tempfile).to receive(:new).and_return(temp_file)
      allow(temp_file).to receive(:write)
      allow(temp_file).to receive(:rewind)
      allow(temp_file).to receive(:path).and_return("/tmp/test_config.json")
      allow(temp_file).to receive(:close)
      allow(temp_file).to receive(:unlink)
      allow(Instagram::ChallengeConfigurable).to receive(:create_temp_config).and_return(temp_file)
      allow(Instagram::ChallengeConfigurable).to receive(:execute_script_with_config).and_return({ "messages" => [] })
    end

    it "récupère les messages avec succès" do
      result = described_class.call(
        username: username,
        password: password,
        recipient_id: recipient_id,
        hours_back: hours_back
      )

      expect(result).to eq([])
      expect(Instagram::ChallengeConfigurable).to have_received(:create_temp_config).with(username, password)
      expect(Instagram::ChallengeConfigurable).to have_received(:execute_script_with_config).with(
        "fetch_messages.py",
        "/tmp/test_config.json",
        recipient_id,
        "--hours-back",
        "24.0"
      )
    end

    it "nettoie le fichier temporaire même en cas d'erreur" do
      allow(Instagram::ChallengeConfigurable).to receive(:execute_script_with_config).and_raise("Erreur test")

      expect {
        described_class.call(
          username: username,
          password: password,
          recipient_id: recipient_id,
          hours_back: hours_back
        )
      }.to raise_error("Erreur test")

      expect(temp_file).to have_received(:close)
      expect(temp_file).to have_received(:unlink)
    end

    it "retourne directement le résultat si pas de clé 'messages'" do
      allow(Instagram::ChallengeConfigurable).to receive(:execute_script_with_config).and_return({ "data" => "test" })

      result = described_class.call(
        username: username,
        password: password,
        recipient_id: recipient_id,
        hours_back: hours_back
      )

      expect(result).to eq({ "data" => "test" })
    end

    context "validation des paramètres" do
      it "lève une erreur si username est vide" do
        expect {
          described_class.call(
            username: "",
            password: password,
            recipient_id: recipient_id,
            hours_back: hours_back
          )
        }.to raise_error(ArgumentError, /Username et password sont requis/)
      end

      it "lève une erreur si password est vide" do
        expect {
          described_class.call(
            username: username,
            password: "",
            recipient_id: recipient_id,
            hours_back: hours_back
          )
        }.to raise_error(ArgumentError, /Username et password sont requis/)
      end

      it "lève une erreur si username est nil" do
        expect {
          described_class.call(
            username: nil,
            password: password,
            recipient_id: recipient_id,
            hours_back: hours_back
          )
        }.to raise_error(ArgumentError, /Username et password sont requis/)
      end

      it "lève une erreur si password est nil" do
        expect {
          described_class.call(
            username: username,
            password: nil,
            recipient_id: recipient_id,
            hours_back: hours_back
          )
        }.to raise_error(ArgumentError, /Username et password sont requis/)
      end

      it "lève une erreur si recipient_id n'est pas un nombre" do
        expect {
          described_class.call(
            username: username,
            password: password,
            recipient_id: "abc",
            hours_back: hours_back
          )
        }.to raise_error(ArgumentError, /user_id doit être un nombre/)
      end

      it "lève une erreur si hours_back est négatif" do
        expect {
          described_class.call(
            username: username,
            password: password,
            recipient_id: recipient_id,
            hours_back: -1
          )
        }.to raise_error(ArgumentError, /hours_back doit être entre 0 et 8760/)
      end

      it "lève une erreur si hours_back est supérieur à 8760" do
        expect {
          described_class.call(
            username: username,
            password: password,
            recipient_id: recipient_id,
            hours_back: 8761
          )
        }.to raise_error(ArgumentError, /hours_back doit être entre 0 et 8760/)
      end

      it "accepte hours_back égal à 0" do
        expect {
          described_class.call(
            username: username,
            password: password,
            recipient_id: recipient_id,
            hours_back: 0
          )
        }.not_to raise_error
      end

      it "accepte hours_back égal à 8760" do
        expect {
          described_class.call(
            username: username,
            password: password,
            recipient_id: recipient_id,
            hours_back: 8760
          )
        }.not_to raise_error
      end

      it "accepte hours_back comme string" do
        expect {
          described_class.call(
            username: username,
            password: password,
            recipient_id: recipient_id,
            hours_back: "24"
          )
        }.not_to raise_error
      end

      it "accepte hours_back comme float" do
        expect {
          described_class.call(
            username: username,
            password: password,
            recipient_id: recipient_id,
            hours_back: 24.5
          )
        }.not_to raise_error
      end
    end
  end
end
