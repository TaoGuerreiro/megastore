# frozen_string_literal: true

module Admin
  class VenuesController < AdminController
    before_action :set_venue, only: %i[edit update destroy]

    def index
      @venues = Venue.order(:name)
    end

    def new
      @venue = Venue.new
      authorize! @venue
    end

    def edit
      authorize! @venue
    end

    def create
      @venue = Venue.new(venue_params)
      authorize! @venue
      if @venue.save
        if @venue.instagram_handle.present?
          InstagramUserIdJob.perform_async(
            "Venue",
            @venue.id,
            current_user.instagram_username,
            current_user.instagram_password,
            @venue.instagram_handle
          )
        end
        respond_to do |format|
          format.html { redirect_to admin_venues_path, notice: t(".success") }
          format.turbo_stream
        end
      else
        render :new, status: :unprocessable_entity, notice: t(".error")
      end
    end

    def update
      authorize! @venue
      old_handle = @venue.instagram_handle_was
      if @venue.update(venue_params)
        if @venue.instagram_handle.present? && @venue.instagram_handle != old_handle
          InstagramUserIdJob.perform_async(
            "Venue",
            @venue.id,
            current_user.instagram_username,
            current_user.instagram_password,
            @venue.instagram_handle
          )
        end
        respond_to do |format|
          format.html { redirect_to admin_venues_path, notice: t(".success") }
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(@venue, partial: "admin/venues/venue", locals: { venue: @venue })
          end
        end
      else
        render :edit, status: :unprocessable_entity, notice: t(".error")
      end
    end

    def destroy
      authorize! @venue
      @venue.destroy
      respond_to do |format|
        format.html { redirect_to admin_venues_path, status: :see_other, notice: t(".success") }
        format.turbo_stream
      end
    end

    private

    def set_venue
      @venue = Venue.find(params[:id])
    end

    def venue_params
      params.require(:venue).permit(:name, :address, :city, :state, :zip_code, :country, :phone, :email, :capacity,
                                    :language, :instagram_handle)
    end
  end
end
