require "rails_helper"

RSpec.describe BookingMailer, type: :mailer do
  describe "premier_contact" do
    let(:venue) { create(:venue, name: "Salle 2") }
    let(:booking_contact) { create(:booking_contact, email: "contact2@example.com", name: "Contact 2", language: "fr") }
    let(:booking) { create(:booking, venue: venue, booking_contact: booking_contact) }
    let(:mail) { BookingMailer.premier_contact(booking) }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t("booking_mailer.premier_contact.subject", venue: booking.venue.name, locale: booking.booking_contact.language))
      expect(mail.to).to eq([booking.booking_contact.email])
      expect(mail.from).to eq([BookingMailer.default[:from]])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("Hello Contact 2")
      expect(mail.body.encoded).to include("Salle 2")
      expect(mail.body.encoded).to include("booking request")
    end
  end
end
