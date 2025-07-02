class SendInstagramMessageJob < ApplicationJob
  queue_as :default

  def perform(booking_message_id)
    message = BookingMessage.find(booking_message_id)
    booking = message.booking
    user = message.user
    recipient_handle = booking.booking_contact&.instagram_handle&.delete_prefix("@")

    unless recipient_handle.present?
      message.update!(status: :failed)
      return
    end

    begin
      Instagram::SendMessage.new(
        sender: user,
        recipient_handle:,
        message: message.text
      ).call
      message.update!(status: :sent, sent_via_instagram: true)
    rescue StandardError => e
      Rails.logger.error("Erreur Instagram async: #{e}")
      message.update!(status: :failed)
    end
  end
end
