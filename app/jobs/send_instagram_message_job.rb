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
      result = Instagram::SendMessageService.call(
        username: user.instagram_username,
        password: user.instagram_password,
        recipient_id:,
        message: message.text
      )

      # Mise à jour du message avec les informations Instagram
      update_params = {
        status: :sent
      }

      # Ajout des informations Instagram si disponibles
      if result.is_a?(Hash)
        update_params[:instagram_message_id] = result["instagram_message_id"] if result["instagram_message_id"].present?
        if result["instagram_sender_username"].present?
          update_params[:instagram_sender_username] = result["instagram_sender_username"]
        end
        if result["instagram_timestamp"].present?
          update_params[:instagram_timestamp] = Time.parse(result["instagram_timestamp"])
        end
      end

      message.update!(update_params)
    rescue StandardError => e
      Rails.logger.error("SendInstagramMessageJob: Erreur Instagram async: #{e}")
      message.update!(status: :failed)
    end
  end
end
