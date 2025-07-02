class BookingMessage < ApplicationRecord
  belongs_to :booking
  belongs_to :user

  validates :text, presence: true, length: { maximum: 2000 }

  enum status: {
    pending: "pending",
    sent: "sent",
    failed: "failed"
  }

  # Broadcast Turbo Streams pour mettre à jour l'icône sans rechargement
  after_update_commit lambda {
                        broadcast_replace_later_to "booking_#{booking.id}_messages", target: "booking_message_#{id}"
                      }
  after_create_commit -> { broadcast_append_later_to "booking_#{booking.id}_messages", target: "chat_messages" }

  scope :ordered_by_timestamp, -> { order(Arel.sql("COALESCE(instagram_timestamp, created_at) ASC")) }

  def pending?
    status == "pending"
  end

  def sent?
    status == "sent"
  end

  def failed?
    status == "failed"
  end

  def sender_display_name
    booking.booking_contact.name
  end

  def display_timestamp
    instagram_timestamp || created_at
  end
end
