class BookingMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.booking_mailer.premier_contact.subject
  #
  def premier_contact(booking)
    binding.pry
    @booking = booking
    @contact = booking.booking_contact
    @venue = booking.venue
    recipient = @contact&.email.presence || @venue&.email.presence
    return unless recipient.present?

    locale = @contact&.locale.presence || @venue&.locale.presence || "fr"
    I18n.with_locale(locale) do
      mail(
        to: recipient,
        subject: I18n.t("booking_mailer.premier_contact.subject", venue: @venue&.name)
      )
    end
  rescue StandardError => e
    @booking.booking_steps.create!(step_type: "erreur_envoi_mail",
                                   comment: "premier_contact: #{e.class} - #{e.message}")
    nil
  end

  def relance(booking)
    @booking = booking
    @contact = booking.booking_contact
    @venue = booking.venue
    recipient = @contact&.email.presence || @venue&.email.presence
    return unless recipient.present?

    locale = @contact&.locale.presence || @venue&.locale.presence || "fr"
    I18n.with_locale(locale) do
      mail(
        to: recipient,
        subject: I18n.t("booking_mailer.relance.subject", venue: @venue&.name)
      )
    end
  rescue StandardError => e
    @booking.booking_steps.create!(step_type: "erreur_envoi_mail", comment: "relance: #{e.class} - #{e.message}")
    nil
  end
end
