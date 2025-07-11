class FetchInstagramMessagesJob < ApplicationJob
  queue_as :default

  def perform(user_id = nil, hours_back = 24, recipient_id = nil)
    puts "=== [Sidekiq] FetchInstagramMessagesJob lancé à #{Time.now} ==="

    # Si aucun utilisateur spécifié, récupère tous les utilisateurs avec des credentials Instagram
    users = if user_id
              [User.find(user_id)]
            else
              User.where.not(instagram_username: [nil, ""]).where.not(instagram_password: [nil, ""])
            end

    total_messages = 0
    total_saved = 0

    users.each do |user|
      Rails.logger.info("FetchInstagramMessagesJob: Traitement de l'utilisateur #{user.id}")

      # Si recipient_id est spécifié, on récupère les messages pour ce contact
      if recipient_id.present?
        begin
          messages = Instagram::FetchMessagesService.call(
            username: unsafehc,
            password: "Double-Moresque44",
            recipient_id: "214851658",
            hours_back: "3"
          )
          total_messages += messages.length
          saved_count = process_messages(messages, recipient_id, user)
          total_saved += saved_count
          Rails.logger.info("FetchInstagramMessagesJob: #{messages.length} messages récupérés, #{saved_count} sauvegardés pour l'utilisateur #{user.id} et le contact #{recipient_id}")
        rescue StandardError => e
          Rails.logger.error("FetchInstagramMessagesJob: Erreur pour l'utilisateur #{user.id} et le contact #{recipient_id}: #{e}")
        end
      else
        # Si pas de recipient_id, on récupère les messages pour tous les contacts de cet utilisateur

        # Récupère tous les booking_contacts qui ont un instagram_user_id
        booking_contacts = BookingContact.where.not(instagram_user_id: [nil, ""])
        booking_contacts.each do |contact|
          next unless contact.instagram_user_id.present?

          begin
            messages = Instagram::FetchMessagesService.call(
              username: user.instagram_username,
              password: user.instagram_password,
              recipient_id: contact.instagram_user_id,
              hours_back:
            )
            total_messages += messages.length
            saved_count = process_messages(messages, contact.instagram_user_id, user)
            total_saved += saved_count
            Rails.logger.info("FetchInstagramMessagesJob: #{messages.length} messages récupérés, #{saved_count} sauvegardés pour l'utilisateur #{user.id} et le contact #{contact.instagram_user_id}")
          rescue StandardError => e
            Rails.logger.error("FetchInstagramMessagesJob: Erreur pour l'utilisateur #{user.id} et le contact #{contact.instagram_user_id}: #{e}")
            # Continue avec les autres contacts
          end
        end

        # Récupère tous les venues qui ont un instagram_user_id
        venues = Venue.where.not(instagram_user_id: [nil, ""])
        venues.each do |venue|
          next unless venue.instagram_user_id.present?

          begin
            messages = Instagram::FetchMessagesService.call(
              username: user.instagram_username,
              password: user.instagram_password,
              recipient_id: venue.instagram_user_id,
              hours_back:
            )
            total_messages += messages.length
            saved_count = process_messages(messages, venue.instagram_user_id, user)
            total_saved += saved_count
            Rails.logger.info("FetchInstagramMessagesJob: #{messages.length} messages récupérés, #{saved_count} sauvegardés pour l'utilisateur #{user.id} et la venue #{venue.instagram_user_id}")
          rescue StandardError => e
            Rails.logger.error("FetchInstagramMessagesJob: Erreur pour l'utilisateur #{user.id} et la venue #{venue.instagram_user_id}: #{e}")
            # Continue avec les autres venues
          end
        end
      end
    end
  end

  private

  def process_messages(messages, recipient_id, user)
    return 0 if messages.blank? || !messages.is_a?(Array)

    saved_count = 0

    messages.each do |message_data|
      next unless message_data.is_a?(Hash) && message_data["text"].present?

      # Trouve le booking correspondant au recipient_id
      booking = find_booking_for_recipient(recipient_id)
      next unless booking

      # Vérifie si le message existe déjà
      existing_message = BookingMessage.find_by(
        booking:,
        instagram_message_id: message_data["message_id"]
      )

      next if existing_message

      # Crée le nouveau message
      begin
        booking_message = BookingMessage.create!(
          booking:,
          user:,
          text: message_data["text"],
          status: "sent", # Tous les messages Instagram récupérés sont considérés comme envoyés
          instagram_message_id: message_data["message_id"],
          instagram_sender_id: message_data["sender_id"],
          instagram_sender_username: message_data["sender_username"],
          instagram_sender_full_name: message_data["sender_full_name"],
          instagram_timestamp: Time.parse(message_data["timestamp"]),
          created_at: Time.parse(message_data["datetime"]),
          updated_at: Time.parse(message_data["datetime"])
        )
        saved_count += 1
        Rails.logger.info("FetchInstagramMessagesJob: Message Instagram créé avec l'ID #{booking_message.id}")
      rescue StandardError => e
        Rails.logger.error("FetchInstagramMessagesJob: Erreur lors de la création du message: #{e}")
      end
    end

    saved_count
  end

  def find_booking_for_recipient(recipient_id)
    # Cherche d'abord dans les booking_contacts
    contact = BookingContact.find_by(instagram_user_id: recipient_id)
    if contact
      booking = contact.bookings.first
      return booking if booking
    end

    # Cherche ensuite dans les venues
    venue = Venue.find_by(instagram_user_id: recipient_id)
    if venue
      booking = venue.bookings.first
      return booking if booking
    end

    nil
  end
end
