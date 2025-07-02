# frozen_string_literal: true

module Admin
  class BookingsController < AdminController
    before_action :set_booking,
                  only: %i[show edit update destroy add_step reset_steps create_message fetch_instagram_messages]
    # verify_authorized

    def index
      @bookings = Booking.includes(:gig, :booking_contact, :venue)
    end

    def show
      authorize! @booking
    end

    def new
      @booking = Booking.new
      @booking.build_gig
      authorize! @booking
    end

    def edit
      authorize! @booking
    end

    def create
      @booking = Booking.new(booking_params)
      authorize! @booking

      if @booking.save
        redirect_to admin_bookings_path, notice: t(".success")
      else
        render :new, status: :unprocessable_entity, notice: t(".error")
      end
    end

    def add_step
      authorize! @booking
      step = @booking.booking_steps.create!(step_type: params[:step_type], comment: params[:comment])
      # Envoie un mail uniquement pour premier_contact ou relance
      BookingMailer.premier_contact(@booking).deliver_later if step.premier_contact?
      BookingMailer.relance(@booking).deliver_later if step.relance?
      # Pour NRP (Non Réponse Possible), seule la step est ajoutée, aucune action supplémentaire
      redirect_to admin_booking_path(@booking), notice: t("admin.bookings.step_added")
    end

    def update
      authorize! @booking
      if @booking.update(booking_params)
        redirect_to admin_bookings_path, status: :see_other, notice: t(".success")
      else
        render :edit, status: :unprocessable_entity, notice: t(".error")
      end
    end

    def destroy
      authorize! @booking
      @booking.destroy
      redirect_to admin_bookings_path, status: :see_other, notice: t(".success")
    end

    def reset_steps
      authorize! @booking
      @booking.booking_steps.destroy_all
      redirect_to admin_booking_path(@booking), notice: t("admin.bookings.steps_reset")
    end

    def create_message
      authorize! @booking
      @message = @booking.booking_messages.build(
        user: current_user,
        text: params[:text]
      )

      if @message.save
        # Envoi Instagram en arrière-plan
        SendInstagramMessageJob.perform_later(@message.id) if @booking.booking_contact&.instagram_user_id.present?

        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to admin_booking_path(@booking) }
        end
      else
        respond_to do |format|
          format.turbo_stream { render :create_message_error }
          format.html { redirect_to admin_booking_path(@booking), alert: "Erreur lors de l'envoi du message" }
        end
      end
    end

    def fetch_instagram_messages
      authorize! @booking
      if @booking.booking_contact&.instagram_user_id.present? && current_user.instagram_username.present? && current_user.instagram_password.present?
        FetchInstagramMessagesJob.perform_later(current_user.id, 24, @booking.booking_contact.instagram_user_id)
        redirect_to admin_booking_path(@booking),
                    notice: "Récupération des messages Instagram lancée. Rafraîchissez la page dans quelques secondes."
      else
        redirect_to admin_booking_path(@booking), alert: "Aucun id Instagram ou credentials manquants."
      end
    end

    private

    def set_booking
      @booking = Booking.find(params[:id])
    end

    def booking_params
      params.require(:booking).permit(:notes, :gig_id, :booking_contact_id, :venue_id, gig_attributes: [:id, :date])
    end
  end
end
