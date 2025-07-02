module Instagram
  class SendMessage
    def initialize(sender:, recipient_handle:, message:)
      @sender = sender # instance User
      @recipient_handle = recipient_handle
      @message = message
    end

    def call
      raise "Identifiants Instagram manquants" if @sender.instagram_username.blank? || @sender.instagram_password.blank?

      client = Instagram::Client.new(username: @sender.instagram_username, password: @sender.instagram_password)
      client.send_message(@recipient_handle, @message)
    end
  end
end
