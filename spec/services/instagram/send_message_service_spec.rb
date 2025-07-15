# frozen_string_literal: true

require "rails_helper"

RSpec.describe Instagram::SendMessageService do
  let(:username) { "test_user" }
  let(:password) { "test_password" }
  let(:recipient_id) { "123456789" }
  let(:message) { "Hello, this is a test message!" }

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
      allow(Instagram::ChallengeConfigurable).to receive(:execute_script_with_config).and_return({ "success" => true, "message_id" => "msg_123" })
    end

    it "envoie le message avec succès" do
      result = described_class.call(
        username: username,
        password: password,
        recipient_id: recipient_id,
        message: message
      )

      expect(result).to eq({ "success" => true, "message_id" => "msg_123" })
      expect(Instagram::ChallengeConfigurable).to have_received(:create_temp_config).with(username, password)
      expect(Instagram::ChallengeConfigurable).to have_received(:execute_script_with_config).with(
        "send_message.py",
        "/tmp/test_config.json",
        recipient_id,
        message
      )
    end

    it "nettoie le fichier temporaire même en cas d'erreur" do
      allow(Instagram::ChallengeConfigurable).to receive(:execute_script_with_config).and_raise("Erreur test")

      expect {
        described_class.call(
          username: username,
          password: password,
          recipient_id: recipient_id,
          message: message
        )
      }.to raise_error("Erreur test")

      expect(temp_file).to have_received(:close)
      expect(temp_file).to have_received(:unlink)
    end

    context "validation des paramètres" do
      it "lève une erreur si username est vide" do
        expect {
          described_class.call(
            username: "",
            password: password,
            recipient_id: recipient_id,
            message: message
          )
        }.to raise_error(ArgumentError, /Username et password sont requis/)
      end

      it "lève une erreur si password est vide" do
        expect {
          described_class.call(
            username: username,
            password: "",
            recipient_id: recipient_id,
            message: message
          )
        }.to raise_error(ArgumentError, /Username et password sont requis/)
      end

      it "lève une erreur si username est nil" do
        expect {
          described_class.call(
            username: nil,
            password: password,
            recipient_id: recipient_id,
            message: message
          )
        }.to raise_error(ArgumentError, /Username et password sont requis/)
      end

      it "lève une erreur si password est nil" do
        expect {
          described_class.call(
            username: username,
            password: nil,
            recipient_id: recipient_id,
            message: message
          )
        }.to raise_error(ArgumentError, /Username et password sont requis/)
      end

      it "lève une erreur si recipient_id n'est pas un nombre" do
        expect {
          described_class.call(
            username: username,
            password: password,
            recipient_id: "abc",
            message: message
          )
        }.to raise_error(ArgumentError, /user_id doit être un nombre/)
      end

      it "lève une erreur si message est vide" do
        expect {
          described_class.call(
            username: username,
            password: password,
            recipient_id: recipient_id,
            message: ""
          )
        }.to raise_error(ArgumentError, /Message est requis/)
      end

      it "lève une erreur si message est nil" do
        expect {
          described_class.call(
            username: username,
            password: password,
            recipient_id: recipient_id,
            message: nil
          )
        }.to raise_error(ArgumentError, /Message est requis/)
      end

      it "lève une erreur si message ne contient que des espaces" do
        expect {
          described_class.call(
            username: username,
            password: password,
            recipient_id: recipient_id,
            message: "   "
          )
        }.to raise_error(ArgumentError, /Message est requis/)
      end

      it "accepte recipient_id comme string numérique" do
        expect {
          described_class.call(
            username: username,
            password: password,
            recipient_id: "123456789",
            message: message
          )
        }.not_to raise_error
      end

      it "accepte recipient_id comme integer" do
        expect {
          described_class.call(
            username: username,
            password: password,
            recipient_id: 123456789,
            message: message
          )
        }.not_to raise_error
      end
    end
  end
end
