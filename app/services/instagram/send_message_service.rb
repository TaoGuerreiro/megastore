# frozen_string_literal: true

module Instagram
  # Service pour envoyer des messages Instagram
  class SendMessageService < BaseService
    def self.call(username:, password:, recipient_id:, message:)
      validate_credentials(username, password)
      validate_user_id(recipient_id)

      raise ArgumentError, "Message est requis" if message.blank?

      execute_script(
        "send_message.py",
        username,
        password,
        recipient_id.to_s,
        message
      )

      # Le nouveau script retourne un hash avec les informations du message
    end
  end
end
