require "rails_helper"

RSpec.describe BookingMailer, type: :mailer do
  describe "premier_contact" do
    let(:mail) { BookingMailer.premier_contact }

    it "renders the headers" do
      expect(mail.subject).to eq("Premier contact")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
