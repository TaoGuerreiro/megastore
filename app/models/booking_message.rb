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

  def pending?
    status == "pending"
  end

  def sent?
    status == "sent"
  end

  def failed?
    status == "failed"
  end
end
