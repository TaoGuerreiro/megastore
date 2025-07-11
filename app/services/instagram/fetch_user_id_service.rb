# frozen_string_literal: true

module Instagram
  # Service pour récupérer l'ID d'un utilisateur Instagram
  class FetchUserIdService < BaseService
    def self.call(username:, password:, handle:)
      validate_credentials(username, password)

      raise ArgumentError, "Handle est requis" if handle.blank?

      result = execute_script("fetch_user_id.py", username, password, handle)

      # Le nouveau script retourne un hash avec user_id
      result["user_id"]
    end
  end
end
