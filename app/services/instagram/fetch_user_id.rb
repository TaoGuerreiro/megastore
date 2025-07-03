# frozen_string_literal: true

require "open3"
require "json"

module Instagram
  class FetchUserId
    SCRIPT_PATH = Rails.root.join("app/instagram_scripts/fetch_user_id.py").to_s

    def self.call(username:, password:, handle:)
      python_executable = if Rails.env.production?
                            "python3"
                          else
                            "venv/bin/python"
                          end
      cmd = [
        python_executable,
        SCRIPT_PATH,
        username,
        password,
        handle
      ]
      stdout, stderr, status = Open3.capture3(*cmd)
      raise "Erreur récupération user_id: #{stderr}" unless status.success?

      result = JSON.parse(stdout)
      raise "Erreur récupération user_id: #{result['error']}" if result.is_a?(Hash) && result["error"]

      result["user_id"]
    end
  end
end
