class SendInstagramMessageJob < ApplicationJob
  queue_as :default

  def perform(booking_message_id)
    message = BookingMessage.find(booking_message_id)
    booking = message.booking
    user = message.user
    recipient_id = booking.booking_contact&.instagram_user_id

    unless recipient_id.present?
      message.update!(status: :failed)
      return
    end

    begin
      Instagram::SendMessage.call(
        username: user.instagram_username,
        password: user.instagram_password,
        recipient_id:,
        message: message.text
      )
      message.update!(status: :sent, sent_via_instagram: true)
    rescue StandardError => e
      Rails.logger.error("SendInstagramMessageJob: Erreur Instagram async: #{e}")
      message.update!(status: :failed)
    end
  end
end
