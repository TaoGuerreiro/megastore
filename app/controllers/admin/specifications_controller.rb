# frozen_string_literal: true

module Admin
  class SpecificationsController < AdminController
    before_action :set_specification, only: %i[edit update destroy]
    before_action :set_store, only: %i[new create edit update destroy]

    def index
      @specifications = Current.store.specifications
    end

    def new
      @specification = Current.store.specifications.build
      authorize! @specification
    end

    def edit; end

    def create
      @specification = Current.store.specifications.build(specification_params)
      authorize! @specification

      if @specification.save
        respond_to do |format|
          format.html { redirect_to admin_store_path, notice: t(".success") }
          format.turbo_stream
        end
      else
        render :new, status: :unprocessable_entity, notice: t(".error")
      end
    end

    def update
      if @specification.update(specification_params)
        respond_to do |format|
          format.html { redirect_to admin_store_path, notice: t(".success") }
          format.turbo_stream
        end
      else
        render :edit, status: :unprocessable_entity, notice: t(".error")
      end
    end

    def destroy
      if @specification.destroy
        respond_to do |format|
          format.html { redirect_to admin_store_path, notice: t(".success") }
          format.turbo_stream
        end
      else
        redirect_to admin_store_path, alert: t(".error")
      end
    end

    private

    def set_specification
      @specification = Current.store.specifications.find(params[:id])
      authorize! @specification
    end

    def set_store
      @store = Current.store
    end

    def specification_params
      params.require(:specification).permit(:name)
    end
  end
end
