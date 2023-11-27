module Admin
  class ItemsController < ApplicationController
    layout "admin"
    before_action :set_shipping_methods, only: [:new, :edit, :create, :update]
    before_action :set_specifications, only: [:new, :edit]

    def index
      @items = filterable(Item, authorized_scope(Item.includes(:photos, :category)))
      authorize! @items
    end

    def new
      @item = Item.new
      authorize! @item
    end

    def create
      @item = Item.new(item_params)
      authorize! @item

      @item.store = current_user.stores.first
      if @item.save
        redirect_to admin_items_path, notice: "Item was successfully created."
      else
        render :new, status: :unprocessable_entity, notice: "Item could not be created."
      end
    end

    def edit
      @item = Item.find(params[:id])
      authorize! @item
    end

    def update
      @item = Item.find(params[:id])
      authorize! @item
      if @item.update(item_params)
        redirect_to admin_items_path, notice: "Item was successfully updated."
      else
        render :edit, status: :unprocessable_entity, notice: "Item could not be updated."
      end
    end

    def destroy
      @item = Item.find(params[:id])
      authorize! @item

      @item.destroy
      redirect_to admin_items_path, notice: "Item was successfully destroyed."
    end

    def remove_photo
      @item = Item.find(params[:id])
      authorize! @item

      # photo = @item.photos.find_by(key: params[:key])
      @photo = @item.photos.attachments.find(params[:photo_id])
      @photo.purge


      respond_to do |format|
        format.html { redirect_to edit_admin_item_path(@item), notice: "Photo was successfully removed." }
        format.turbo_stream
      end
    end

    def archive
      @item = Item.find(params[:id])
      authorize! @item

      @item.archive!
      redirect_to admin_items_path, notice: "Item was successfully archived."
    end

    def unarchive
      @item = Item.find(params[:id])
      authorize! @item

      @item.update(status: :offline)
      redirect_to admin_items_path, notice: "Item was successfully unarchived."
    end

    private

    def set_shipping_methods
      @shipping_methods = authorized_scope(ShippingMethod.all)
    end

    def set_specifications
      @specifications = authorized_scope(Specification.all)
    end

    def item_params
      params.require(:item).permit(:name, :description, :price, :image, :stock, :length, :width, :height, :weight, :category_id, :active, :status, photos: [], shipping_method_ids: [], specification_ids: []).tap do |permitted_params|
        manage_status(permitted_params)
        manage_photos(permitted_params)
        convert_dimensions(permitted_params)
      end
    end

    def manage_status(permitted_params)
      return if permitted_params[:active].nil? || @item&.archived?

      permitted_params[:status] = permitted_params[:active] == "1" ? :active : :offline
    end

    def manage_photos(permitted_params)
      if permitted_params[:photos].reject(&:blank?).first.blank?
        permitted_params.delete(:photos)
      end
    end

    def convert_dimensions(permitted_params)
      [:length, :width, :height].each do |dimension|
        if permitted_params[dimension].present?
          permitted_params[dimension] = permitted_params[dimension].gsub(',', '.').to_f * 10
        end
      end
    end
  end
end
