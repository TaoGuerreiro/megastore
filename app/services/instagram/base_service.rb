# frozen_string_literal: true

require "open3"
require "json"

module Instagram
  # Service de base pour les services Instagram
  class BaseService
    SCRIPTS_DIR = Rails.root.join("app/instagram_scripts/scripts").to_s

    private

    def self.python_executable
      if Rails.env.production?
        "python3"
      else
        "venv/bin/python"
      end
    end

    def self.execute_script(script_name, *args)
      script_path = File.join(SCRIPTS_DIR, script_name)

      raise "Script non trouvé: #{script_path}" unless File.exist?(script_path)

      cmd = [python_executable, script_path, *args]

      Rails.logger.info("Instagram::BaseService: Exécution de #{script_name} avec args: #{args}")

      stdout, stderr, status = Open3.capture3(*cmd)

      unless status.success?
        Rails.logger.error("Instagram::BaseService: Erreur lors de l'exécution de #{script_name}: #{stderr}")
        raise "Erreur lors de l'exécution de #{script_name}: #{stderr}"
      end

      # Parser le résultat JSON
      begin
        result = JSON.parse(stdout)

        # Vérifier s'il y a une erreur dans le résultat
        if result.is_a?(Hash) && result["error"]
          Rails.logger.error("Instagram::BaseService: Erreur dans le résultat de #{script_name}: #{result['error']}")
          raise "Erreur dans le résultat de #{script_name}: #{result['error']}"
        end

        result
      rescue JSON::ParserError => e
        Rails.logger.error("Instagram::BaseService: Erreur de parsing JSON pour #{script_name}: #{e}")
        Rails.logger.error("Instagram::BaseService: Sortie brute: #{stdout}")
        raise "Erreur de parsing JSON pour #{script_name}: #{e}"
      end
    end

    def self.validate_credentials(username, password)
      return unless username.blank? || password.blank?

      raise ArgumentError, "Username et password sont requis"
    end

    def self.validate_user_id(user_id)
      return if user_id.to_s =~ /^\d+$/

      raise ArgumentError, "user_id doit être un nombre"
    end
  end
end
