# frozen_string_literal: true

module Admin
  class BookingContactsController < AdminController
    before_action :set_booking_contact, only: %i[edit update destroy]

    def index
      @booking_contacts = BookingContact.order(:name)
    end

    def new
      @booking_contact = BookingContact.new
      authorize! @booking_contact
    end

    def edit
      authorize! @booking_contact
    end

    def create
      @booking_contact = BookingContact.new(booking_contact_params)
      authorize! @booking_contact
      if @booking_contact.save
        if @booking_contact.instagram_handle.present?
          InstagramUserIdJob.perform_async(
            "BookingContact",
            @booking_contact.id,
            current_user.instagram_username,
            current_user.instagram_password,
            @booking_contact.instagram_handle
          )
        end
        respond_to do |format|
          format.html { redirect_to admin_booking_contacts_path, notice: t(".success") }
          format.turbo_stream
        end
      else
        render :new, status: :unprocessable_entity, notice: t(".error")
      end
    end

    def update
      authorize! @booking_contact
      old_handle = @booking_contact.instagram_handle_was
      if @booking_contact.update(booking_contact_params)
        if @booking_contact.instagram_handle.present? && @booking_contact.instagram_handle != old_handle
          InstagramUserIdJob.perform_async(
            "BookingContact",
            @booking_contact.id,
            current_user.instagram_username,
            current_user.instagram_password,
            @booking_contact.instagram_handle
          )
        end
        respond_to do |format|
          format.html { redirect_to admin_booking_contacts_path, notice: t(".success") }
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(@booking_contact,
                                                      partial: "admin/booking_contacts/booking_contact", locals: { booking_contact: @booking_contact })
          end
        end
      else
        render :edit, status: :unprocessable_entity, notice: t(".error")
      end
    end

    def destroy
      authorize! @booking_contact
      @booking_contact.destroy
      respond_to do |format|
        format.html { redirect_to admin_booking_contacts_path, status: :see_other, notice: t(".success") }
        format.turbo_stream
      end
    end

    private

    def set_booking_contact
      @booking_contact = BookingContact.find(params[:id])
    end

    def booking_contact_params
      params.require(:booking_contact).permit(:name, :email, :phone, :address, :city, :state, :zip_code, :country,
                                              :notes, :language, :instagram_handle)
    end
  end
end
