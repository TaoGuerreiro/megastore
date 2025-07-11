# frozen_string_literal: true

module Instagram
  # Service pour envoyer des messages Instagram
  class SendMessageService < BaseService
    include ChallengeConfigurable

    def self.call(username:, password:, recipient_id:, message:)
      validate_credentials(username, password)
      validate_user_id(recipient_id)

      raise ArgumentError, "Message est requis" if message.blank?

      # Créer un fichier de configuration temporaire avec les credentials
      config_file = ChallengeConfigurable.create_temp_config(username, password)

      begin
        result = ChallengeConfigurable.execute_script_with_config(
          "send_message.py",
          config_file.path,
          recipient_id.to_s,
          message
        )

        # Le nouveau script retourne un hash avec les informations du message
        result
      ensure
        # Nettoyer le fichier temporaire
        config_file.close
        config_file.unlink
      end
    end
  end
end
