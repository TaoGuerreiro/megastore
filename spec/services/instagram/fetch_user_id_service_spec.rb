# frozen_string_literal: true

require "rails_helper"

RSpec.describe Instagram::FetchUserIdService do
  let(:username) { "test_user" }
  let(:password) { "test_password" }
  let(:handle) { "test_handle" }

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
      allow(Instagram::ChallengeConfigurable).to receive(:execute_script_with_config).and_return({ "user_id" => "123456789" })
    end

    it "récupère l'ID utilisateur avec succès" do
      result = described_class.call(
        username: username,
        password: password,
        handle: handle
      )

      expect(result).to eq("123456789")
      expect(Instagram::ChallengeConfigurable).to have_received(:create_temp_config).with(username, password)
      expect(Instagram::ChallengeConfigurable).to have_received(:execute_script_with_config).with(
        "fetch_user_id.py",
        "/tmp/test_config.json",
        handle
      )
    end

    it "nettoie le fichier temporaire même en cas d'erreur" do
      allow(Instagram::ChallengeConfigurable).to receive(:execute_script_with_config).and_raise("Erreur test")

      expect {
        described_class.call(
          username: username,
          password: password,
          handle: handle
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
            handle: handle
          )
        }.to raise_error(ArgumentError, /Username et password sont requis/)
      end

      it "lève une erreur si password est vide" do
        expect {
          described_class.call(
            username: username,
            password: "",
            handle: handle
          )
        }.to raise_error(ArgumentError, /Username et password sont requis/)
      end

      it "lève une erreur si username est nil" do
        expect {
          described_class.call(
            username: nil,
            password: password,
            handle: handle
          )
        }.to raise_error(ArgumentError, /Username et password sont requis/)
      end

      it "lève une erreur si password est nil" do
        expect {
          described_class.call(
            username: username,
            password: nil,
            handle: handle
          )
        }.to raise_error(ArgumentError, /Username et password sont requis/)
      end

      it "lève une erreur si handle est vide" do
        expect {
          described_class.call(
            username: username,
            password: password,
            handle: ""
          )
        }.to raise_error(ArgumentError, /Handle est requis/)
      end

      it "lève une erreur si handle est nil" do
        expect {
          described_class.call(
            username: username,
            password: password,
            handle: nil
          )
        }.to raise_error(ArgumentError, /Handle est requis/)
      end

      it "lève une erreur si handle ne contient que des espaces" do
        expect {
          described_class.call(
            username: username,
            password: password,
            handle: "   "
          )
        }.to raise_error(ArgumentError, /Handle est requis/)
      end
    end
  end
end
