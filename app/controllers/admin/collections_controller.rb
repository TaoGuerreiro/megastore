class Admin::CollectionsController < ApplicationController
  def create
    @collection = Collection.new(collection_params)
    if @collection.save
      redirect_to admin_items_path, notice: 'Collection was successfully created.'
    else
      @collections = Collection.all
      render "admin/items/index", status: :unprocessable_entity
    end
  end

  def destroy
    @collection = Collection.find(params[:id])
    @collection.destroy
    redirect_to admin_items_path, status: :see_other, notice: 'Collection was successfully destroyed.'
  end

  private

  def collection_params
    params.require(:collection).permit(:name)
  end
end
