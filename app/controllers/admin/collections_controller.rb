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
          format.html { redirect_to admin_collections_path, notice: "Collection was successfully created." }
          format.turbo_stream do
            render turbo_stream: turbo_stream.append("collections", partial: "admin/collections/collection",
                                                                    locals: { collection: @collection })
          end
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @collection = Collection.find(params[:id])

      if @collection.update(collection_params)
        respond_to do |format|
          format.html { redirect_to admin_collections_path, notice: "Collection was successfully updated." }
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(@collection, partial: "admin/collections/collection",
                                                                   locals: { collection: @collection })
          end
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @collection = Collection.find(params[:id])
      @collection.destroy

      respond_to do |format|
        format.html { redirect_to admin_collections_path }
        format.turbo_stream { render turbo_stream: turbo_stream.remove(@collection) }
      end
    end

    private

    def collection_params
      params.require(:collection).permit(:name)
    end
  end
end
