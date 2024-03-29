# frozen_string_literal: true

module Admin
  class CategoriesController < AdminController
    before_action :set_category, only: %i[edit update destroy]
    before_action :set_store, only: %i[new create edit update destroy]

    def new
      @category = Current.store.categories.build
      authorize! @category
    end

    def create
      @category = Current.store.categories.build(category_params)
      authorize! @category

      if @category.save
        respond_to do |format|
          format.html { redirect_to admin_store_path, notice: 'Category was successfully created.' }
          format.turbo_stream
        end
      else
        render :new
      end
    end

    def edit; end

    def update
      if @category.update(category_params)
        redirect_to admin_store_path, notice: 'Category was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      begin
        @category.destroy!
      rescue StandardError
      end

      respond_to do |format|
        format.html { redirect_to admin_store_path, status: :see_othet }
        format.turbo_stream
      end
    end

    private

    def set_category
      @category = Current.store.categories.find(params[:id])
      authorize! @category
    end

    def set_store
      @store = Current.store
    end

    def category_params
      params.require(:category).permit(:name)
    end
  end
end
