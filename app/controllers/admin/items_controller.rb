module Admin
  class ItemsController < ApplicationController
    layout "admin"

    def index
      @items = Item.all
    end

    def new
      @item = Item.new
    end

    def create
      # raise
      @item = Item.new(item_params)
      @item.store = current_user.stores.first
      if @item.save
        redirect_to admin_items_path
      else
        render :new, status: :unprocessable_entity, notice: "Item could not be created."
      end
    end

    def edit
      @item = Item.find(params[:id])
    end

    def update
      @item = Item.find(params[:id])
      if @item.update(item_params)
        redirect_to admin_items_path
      else
        render :edit, status: :unprocessable_entity, notice: "Item could not be updated."
      end
    end

    def destroy
      @item = Item.find(params[:id])
      @item.destroy
      redirect_to admin_items_path
    end

    def remove_photo
      @item = Item.find(params[:id])

      # photo = @item.photos.find_by(key: params[:key])
      photo = @item.photos.attachments.find(params[:photo_id])
      photo.purge

      redirect_to edit_admin_item_path(@item)
    end

    private

    def item_params
      if params[:item][:photos].first.blank?
        params.require(:item).permit(:name, :description, :price, :image, :stock, :category_id, :active)
      else
        params.require(:item).permit(:name, :description, :price, :image, :stock, :category_id, :active, photos: [])
      end
    end
  end
end
