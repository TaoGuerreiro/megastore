module Admin
  class ItemsController < ApplicationController
    layout "admin"

    def index
      @items = Item.with_archived.where(store: Current.store)
    end

    def new
      @item = Item.new
    end

    def create
      # raise
      @item = Item.new(item_params)
      @item.store = current_user.stores.first
      if @item.save
        redirect_to admin_items_path, notice: "Item was successfully created."
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
        redirect_to admin_items_path, notice: "Item was successfully updated."
      else
        render :edit, status: :unprocessable_entity, notice: "Item could not be updated."
      end
    end

    def destroy
      @item = Item.find(params[:id])
      @item.destroy
      redirect_to admin_items_path, notice: "Item was successfully destroyed."
    end

    def remove_photo
      @item = Item.find(params[:id])

      # photo = @item.photos.find_by(key: params[:key])
      photo = @item.photos.attachments.find(params[:photo_id])
      photo.purge

      redirect_to edit_admin_item_path(@item), notice: "Photo was successfully removed."
    end

    def archive
      @item = Item.find(params[:id])
      @item.archive!
      redirect_to admin_items_path, notice: "Item was successfully archived."
    end

    def unarchive
      @item = Item.find(params[:id])
      @item.update(status: :offline)
      redirect_to admin_items_path, notice: "Item was successfully unarchived."
    end

    private

    def item_params
      params.require(:item).permit(:name, :description, :price, :image, :stock, :length, :width, :height, :weight, :category_id, :active, :status, photos: [], shipping_method_ids: []).tap do |permitted_params|
        manage_status(permitted_params)
        manage_photos(permitted_params)
      end
    end

    def manage_status(permitted_params)
      return unless @item
      return if permitted_params[:active].nil? || @item.archived?

      permitted_params[:status] = permitted_params[:active] == "1" ? :active : :offline
    end

    def manage_photos(permitted_params)
      # raise
      if permitted_params[:photos].reject(&:blank?).first.blank?
        permitted_params.delete(:photos)
      end
    end
  end
end
