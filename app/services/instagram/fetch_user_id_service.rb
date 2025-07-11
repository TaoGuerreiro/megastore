# frozen_string_literal: true

module Instagram
  # Service pour récupérer l'ID d'un utilisateur Instagram
  class FetchUserIdService < BaseService
    include ChallengeConfigurable

    def self.call(username:, password:, handle:)
      validate_credentials(username, password)

      raise ArgumentError, "Handle est requis" if handle.blank?

      # Créer un fichier de configuration temporaire avec les credentials
      config_file = ChallengeConfigurable.create_temp_config(username, password)

      begin
        result = ChallengeConfigurable.execute_script_with_config(
          "fetch_user_id.py",
          config_file.path,
          handle
        )

        # Le nouveau script retourne un hash avec user_id
        result["user_id"]
      ensure
        # Nettoyer le fichier temporaire
        config_file.close
        config_file.unlink
      end
    end
  end
end
