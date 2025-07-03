# frozen_string_literal: true

require "open3"

module Instagram
  class SendMessage
    def self.call(username:, password:, recipient_id:, message:)
      raise ArgumentError, "send_message attend un user_id numérique" unless recipient_id.to_s =~ /^\d+$/

      cmd = [
        "venv/bin/python",
        Rails.root.join("app/instagram_scripts/send_message.py").to_s,
        username,
        password,
        recipient_id.to_s,
        message
      ]

      stdout, stderr, status = Open3.capture3(*cmd)

      raise "Erreur envoi message Instagram: #{stderr}" unless status.success?

      result = begin
        JSON.parse(stdout)
      rescue StandardError
        nil
      end
      raise "Erreur envoi message Instagram: #{result['error']}" if result.is_a?(Hash) && result["error"]

      result
    end
  end
end
