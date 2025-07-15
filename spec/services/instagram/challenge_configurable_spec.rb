# frozen_string_literal: true

require "rails_helper"

RSpec.describe Instagram::ChallengeConfigurable do
  describe ".create_temp_config" do
    let(:username) { "test_user" }
    let(:password) { "test_password" }
    let(:temp_file) { instance_double(Tempfile) }

    before do
      allow(Tempfile).to receive(:new).and_return(temp_file)
      allow(temp_file).to receive(:write)
      allow(temp_file).to receive(:rewind)
      allow(temp_file).to receive(:path).and_return("/tmp/test_config.json")
    end

    it "crée un fichier de configuration temporaire" do
      allow(described_class).to receive(:get_challenge_config).and_return({})

      result = described_class.create_temp_config(username, password)

      expect(result).to eq(temp_file)
      expect(temp_file).to have_received(:write).with({
        "username" => username,
        "password" => password,
        "challenge_config" => {}
      }.to_json)
      expect(temp_file).to have_received(:rewind)
    end
  end

  describe ".get_challenge_config" do
    let(:credentials) { double("credentials") }

    before do
      allow(Rails.application).to receive(:credentials).and_return(credentials)
      allow(credentials).to receive(:instagram).and_return(instagram_creds)
    end

    context "avec toutes les configurations disponibles" do
      let(:instagram_creds) do
        double("instagram_creds",
               two_captcha_api_key: "test_2captcha_key",
               email: "test@example.com",
               email_password: "email_password",
               sms_phone: "+33123456789")
      end

      before do
        allow(ENV).to receive(:fetch).with("CHALLENGE_SMS_PROVIDER", "twilio").and_return("twilio")
        allow(ENV).to receive(:fetch).with("CHALLENGE_SMS_ACCOUNT_SID", nil).and_return("test_sid")
        allow(ENV).to receive(:fetch).with("CHALLENGE_SMS_AUTH_TOKEN", nil).and_return("test_token")
      end

      it "retourne la configuration complète" do
        result = described_class.get_challenge_config

        expect(result).to include(
          "two_captcha_api_key" => "test_2captcha_key",
          "challenge_email" => {
            "email" => "test@example.com",
            "password" => "email_password",
            "imap_server" => "imap.gmail.com"
          },
          "challenge_sms" => {
            "phone_number" => "+33123456789",
            "provider" => "twilio",
            "account_sid" => "test_sid",
            "auth_token" => "test_token"
          }
        )
      end
    end

    context "sans configuration 2captcha" do
      let(:instagram_creds) do
        double("instagram_creds",
               two_captcha_api_key: nil,
               email: "test@example.com",
               email_password: "email_password",
               sms_phone: nil)
      end

      it "n'inclut pas la configuration 2captcha" do
        result = described_class.get_challenge_config

        expect(result).not_to have_key("two_captcha_api_key")
        expect(result).to include(
          "challenge_email" => {
            "email" => "test@example.com",
            "password" => "email_password",
            "imap_server" => "imap.gmail.com"
          }
        )
      end
    end

    context "sans configuration email" do
      let(:instagram_creds) do
        double("instagram_creds",
               two_captcha_api_key: "test_key",
               email: nil,
               email_password: nil,
               sms_phone: nil)
      end

      it "n'inclut pas la configuration email" do
        result = described_class.get_challenge_config

        expect(result).not_to have_key("challenge_email")
        expect(result).to include("two_captcha_api_key" => "test_key")
      end
    end

    context "sans configuration SMS" do
      let(:instagram_creds) do
        double("instagram_creds",
               two_captcha_api_key: "test_key",
               email: "test@example.com",
               email_password: "email_password",
               sms_phone: nil)
      end

      it "n'inclut pas la configuration SMS" do
        result = described_class.get_challenge_config

        expect(result).not_to have_key("challenge_sms")
        expect(result).to include(
          "two_captcha_api_key" => "test_key",
          "challenge_email" => {
            "email" => "test@example.com",
            "password" => "email_password",
            "imap_server" => "imap.gmail.com"
          }
        )
      end
    end
  end

  describe ".execute_script_with_config" do
    let(:script_name) { "test_script.py" }
    let(:config_file_path) { "/tmp/config.json" }
    let(:script_path) { File.join(Instagram::BaseService::SCRIPTS_DIR, script_name) }

    before do
      allow(File).to receive(:exist?).with(script_path).and_return(true)
      allow(Instagram::BaseService).to receive(:python_executable).and_return("python3")
    end

    context "quand le script existe" do
      it "exécute le script avec succès" do
        allow(Open3).to receive(:capture3).and_return(['{"success": true}', "", double(success?: true)])

        result = described_class.execute_script_with_config(script_name, config_file_path, "arg1", "arg2")

        expect(result).to eq({ "success" => true })
        expect(Open3).to have_received(:capture3).with("python3", script_path, config_file_path, "arg1", "arg2")
      end

      it "lève une erreur si le script échoue" do
        allow(Open3).to receive(:capture3).and_return(["", "Erreur script", double(success?: false)])

        expect { described_class.execute_script_with_config(script_name, config_file_path) }.to raise_error(/Erreur lors de l'exécution/)
      end

      it "lève une erreur si le résultat contient une erreur" do
        allow(Open3).to receive(:capture3).and_return(['{"error": "Erreur interne"}', "", double(success?: true)])

        expect { described_class.execute_script_with_config(script_name, config_file_path) }.to raise_error(/Erreur dans le résultat/)
      end

      it "lève une erreur si le JSON est invalide" do
        allow(Open3).to receive(:capture3).and_return(['{"invalid json', "", double(success?: true)])

        expect { described_class.execute_script_with_config(script_name, config_file_path) }.to raise_error(/Erreur de parsing JSON/)
      end
    end

    context "quand le script n'existe pas" do
      it "lève une erreur" do
        allow(File).to receive(:exist?).with(script_path).and_return(false)

        expect { described_class.execute_script_with_config(script_name, config_file_path) }.to raise_error(/Script non trouvé/)
      end
    end
  end
end
