# frozen_string_literal: true

module Instagram
  # Service pour récupérer les messages Instagram
  class FetchMessagesService < BaseService
    include ChallengeConfigurable

    def self.call(username:, password:, recipient_id:, hours_back: 24)
      validate_credentials(username, password)
      validate_user_id(recipient_id)

      # Validation du hours_back
      hours_back = hours_back.to_f
      raise ArgumentError, "hours_back doit être entre 0 et 8760" if hours_back < 0 || hours_back > 8760 # Max 1 an

      # Créer un fichier de configuration temporaire avec les credentials
      config_file = ChallengeConfigurable.create_temp_config(username, password)

      begin
        result = ChallengeConfigurable.execute_script_with_config(
          "fetch_messages.py",
          config_file.path,
          recipient_id.to_s,
          "--hours-back", hours_back.to_s
        )

        # Le nouveau script retourne directement la liste des messages
        result["messages"] || result
      ensure
        # Nettoyer le fichier temporaire
        config_file.close
        config_file.unlink
      end
    end
  end
end
