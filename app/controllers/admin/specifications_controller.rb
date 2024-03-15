# frozen_string_literal: true

module Admin
  class SpecificationsController < AdminController
    before_action :set_specification, only: %i[edit update destroy]
    before_action :set_store, only: %i[new create edit update destroy]

    def new
      @specification = Current.store.specifications.build
      authorize! @specification
    end

    def create
      @specification = Current.store.specifications.build(specification_params)
      authorize! @specification

      if @specification.save
        respond_to do |format|
          format.html { redirect_to admin_store_path, notice: 'Shipping method was successfully created.' }
          format.turbo_stream
        end
      else
        render :new
      end
    end

    def edit; end

    def update
      if @specification.update(specification_params)
        respond_to do |format|
          format.html { redirect_to admin_store_path, notice: 'Shipping method was successfully updated.' }
          format.turbo_stream
        end
      else
        render :edit
      end
    end

    def destroy
      if @specification.destroy
        flash[:notice] = 'Shipping method was successfully destroyed.'
        respond_to do |format|
          format.html { redirect_to admin_store_path, notice: 'Shipping method was successfully destroyed.' }
          format.turbo_stream
        end
      else
        redirect_to admin_store_path, alert: 'Shipping method was not destroyed.'
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
