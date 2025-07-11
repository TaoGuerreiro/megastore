# frozen_string_literal: true

module Instagram
  # Module partagé pour la configuration de challenge
  module ChallengeConfigurable
    extend ActiveSupport::Concern

    private

    def self.create_temp_config(username, password)
      require "tempfile"

      config_file = Tempfile.new(["instagram_config", ".json"])
      config = {
        "username" => username,
        "password" => password,
        "challenge_config" => get_challenge_config
      }
      config_file.write(config.to_json)
      config_file.rewind
      config_file
    end

    def self.get_challenge_config
      challenge_config = {}

      # Configuration 2captcha
      two_captcha_key = Rails.application.credentials.instagram&.two_captcha_api_key

      challenge_config["two_captcha_api_key"] = two_captcha_key if two_captcha_key.present?

      # Configuration email
      email_config = {
        "email" => Rails.application.credentials.instagram&.email,
        "password" => Rails.application.credentials.instagram&.email_password,
        "imap_server" => "imap.gmail.com"
      }

      # N'ajouter la config email que si email et password sont présents
      if email_config["email"].present? && email_config["password"].present?
        challenge_config["challenge_email"] = email_config
      end

      # Configuration SMS (optionnelle)
      sms_phone = Rails.application.credentials.instagram&.sms_phone

      if sms_phone.present?
        challenge_config["challenge_sms"] = {
          "phone_number" => sms_phone,
          "provider" => ENV.fetch("CHALLENGE_SMS_PROVIDER", "twilio"),
          "account_sid" => ENV.fetch("CHALLENGE_SMS_ACCOUNT_SID", nil),
          "auth_token" => ENV.fetch("CHALLENGE_SMS_AUTH_TOKEN", nil)
        }
      end

      challenge_config
    end

    def self.execute_script_with_config(script_name, config_file_path, *args)
      # Utiliser les constantes de BaseService
      scripts_dir = Instagram::BaseService::SCRIPTS_DIR
      script_path = File.join(scripts_dir, script_name)

      raise "Script non trouvé: #{script_path}" unless File.exist?(script_path)

      cmd = [Instagram::BaseService.python_executable, script_path, config_file_path, *args]

      Rails.logger.info("Instagram::ChallengeConfigurable: Exécution de #{script_name} avec config")

      stdout, stderr, status = Open3.capture3(*cmd)

      unless status.success?
        Rails.logger.error("Instagram::ChallengeConfigurable: Erreur lors de l'exécution de #{script_name}: #{stderr}")
        raise "Erreur lors de l'exécution de #{script_name}: #{stderr}"
      end

      # Parser le résultat JSON
      begin
        result = JSON.parse(stdout)

        # Vérifier s'il y a une erreur dans le résultat
        if result.is_a?(Hash) && result["error"]
          Rails.logger.error("Instagram::ChallengeConfigurable: Erreur dans le résultat de #{script_name}: #{result['error']}")
          raise "Erreur dans le résultat de #{script_name}: #{result['error']}"
        end

        result
      rescue JSON::ParserError => e
        Rails.logger.error("Instagram::ChallengeConfigurable: Erreur de parsing JSON pour #{script_name}: #{e}")
        Rails.logger.error("Instagram::ChallengeConfigurable: Sortie brute: #{stdout}")
        raise "Erreur de parsing JSON pour #{script_name}: #{e}"
      end
    end
  end
end
