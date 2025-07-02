require "open3"

module Instagram
  class Client
    SCRIPT_PATH = Rails.root.join("app/instagram_scripts")
    PYTHON_BIN = Rails.root.join("venv/bin/python")

    def initialize(username:, password:)
      @username = username
      @password = password
    end

    def send_message(recipient_handle, message)
      script = SCRIPT_PATH.join("send_message.py")
      cmd = [
        PYTHON_BIN.to_s,
        script.to_s,
        @username.to_s,
        @password.to_s,
        recipient_handle.to_s,
        message.to_s
      ]
      stdout, stderr, status = Open3.capture3(*cmd)
      unless status.success?
        Rails.logger.error("Instagram send_message error: #{stderr}")
        raise "Erreur lors de l'envoi du message Instagram : #{stderr}"
      end
      stdout
    end
  end
end
