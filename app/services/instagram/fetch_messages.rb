# frozen_string_literal: true

require "open3"
require "json"

module Instagram
  class FetchMessages
    def self.call(username:, password:, recipient_id:, hours_back: 0.5)
      raise ArgumentError, "fetch_messages attend un user_id numérique" unless recipient_id.to_s =~ /^\d+$/

      python_executable = if Rails.env.production?
                            "python3"
                          else
                            "venv/bin/python"
                          end
      cmd = [
        python_executable,
        Rails.root.join("app/instagram_scripts/fetch_messages.py").to_s,
        username,
        password,
        hours_back.to_s,
        recipient_id.to_s
      ]

      stdout, stderr, status = Open3.capture3(*cmd)
      raise "Erreur récupération messages Instagram: #{stderr}" unless status.success?

      result = begin
        JSON.parse(stdout)
      rescue StandardError
        nil
      end
      raise "Erreur récupération messages Instagram: #{result['error']}" if result.is_a?(Hash) && result["error"]

      result
    end
  end
end
