# frozen_string_literal: true

module Admin
  class CollectionsController < AdminController
    def index
      @collections = authorized_scope(Collection.all)
    end

    def new
      @collection = Collection.new
    end

    def edit
      @collection = Collection.find(params[:id])
    end

    def create
      @collection = Collection.new(collection_params)
      @collection.store = Current.store

      if @collection.save
        respond_to do |format|
          format.html { redirect_to admin_collections_path, notice: t(".success") }
          format.turbo_stream
        end
      else
        render :new, status: :unprocessable_entity, notice: t(".error")
      end
    end

    def update
      @collection = Collection.find(params[:id])

      if @collection.update(collection_params)
        respond_to do |format|
          format.html { redirect_to admin_collections_path, notice: t(".success") }
          format.turbo_stream
        end
      else
        render :edit, status: :unprocessable_entity, notice: t(".error")
      end
    end

    def destroy
      @collection = Collection.find(params[:id])
      @collection.destroy

      respond_to do |format|
        format.html { redirect_to admin_collections_path }
        format.turbo_stream
      end
    end

    private

    def collection_params
      params.require(:collection).permit(:name)
    end
  end
end
