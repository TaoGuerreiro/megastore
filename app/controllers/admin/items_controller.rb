# frozen_string_literal: true

module Admin
  class ItemsController < AdminController
    before_action :set_shipping_methods, only: %i[new edit create update]
    before_action :set_specifications, only: %i[new edit]

    def index
      @active_items_count = Item.where(store: Current.store, status: :active).count
      @offline_items_count = Item.where(store: Current.store, status: :offline).count
      @archived_items_count = Item.where(store: Current.store, status: :archived).count

      # @collections = Collection.all

      @items = filterable(Item, authorized_scope(Item.includes(:photos, :category)))
      @pagy, @items = pagy(@items)

      if params[:search].present?
        @items = @items.search_by_name_and_description(params[:search])
        @pagy, @items = pagy(@items)

        respond_to { |format| format.turbo_stream }
      end

      authorize! @items
    end

    def new
      @item = Item.new
      authorize! @item
    end

    def create
      @item = Item.new(item_params.except(:photos))
      authorize! @item

      @item.store = Store.find_by(domain: request.domain)

      if @item.save
        manage_photos(item_params)
        redirect_to admin_items_path, notice: 'Item was successfully created.'
      else
        render :new, status: :unprocessable_entity, notice: 'Item could not be created.'
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
        redirect_to admin_items_path, notice: 'Item was successfully updated.'
      else
        render :edit, status: :unprocessable_entity, notice: 'Item could not be updated.'
      end
    end

    def destroy
      @item = Item.find(params[:id])
      authorize! @item

      if @item.destroy
        respond_to do |format|
          format.html { redirect_to admin_items_path, notice: 'Item was successfully destroyed.' }
          format.turbo_stream
        end
      else
        respond_to do |format|
          format.html { redirect_to admin_items_path, notice: 'Item could not be destroyed.' }
          format.turbo_stream
        end
      end
    end

    def add_stock
      @item = Item.find(params[:id])
      authorize! @item
      @item.stock += 1
      @item.save
      respond_to do |format|
        format.html { redirect_to admin_items_path, notice: 'Stock was successfully increased.' }
        format.turbo_stream
      end
    end

    def remove_stock
      @item = Item.find(params[:id])
      authorize! @item
      @item.stock -= 1
      @item.save
      respond_to do |format|
        format.html { redirect_to admin_items_path, notice: 'Stock was successfully decreased.' }
        format.turbo_stream
      end
    end

    def remove_photo
      @item = Item.find(params[:id])
      authorize! @item

      # photo = @item.photos.find_by(key: params[:key])
      @photo = @item.photos.attachments.find(params[:photo_id])
      @photo.purge

      respond_to do |format|
        format.html { redirect_to edit_admin_item_path(@item), notice: 'Photo was successfully removed.' }
        format.turbo_stream
      end
    end

    def archive
      @item = Item.find(params[:id])
      authorize! @item

      @item.archive!
      redirect_to admin_items_path, notice: 'Item was successfully archived.'
    end

    def unarchive
      @item = Item.find(params[:id])
      authorize! @item

      @item.update(status: :offline)
      redirect_to admin_items_path, notice: 'Item was successfully unarchived.'
    end

    private

    def set_shipping_methods
      @shipping_methods = []
    end

    def set_specifications
      @specifications = authorized_scope(Specification.all)
    end

    def item_params
      params.require(:item).permit(:name, :description, :price, :image, :stock, :length, :width, :height, :weight,
                                   :category_id, :collection_type, :collection_id, :active, :status, photos: [], shipping_method_ids: [], specification_ids: []).tap do |permitted_params|
        manage_status(permitted_params)
        manage_photos(permitted_params)
        convert_dimensions(permitted_params)
      end
    end

    def manage_status(permitted_params)
      return if permitted_params[:active].nil? || @item&.archived?

      permitted_params[:status] = permitted_params[:active] == '1' ? :active : :offline
    end

    def manage_photos(permitted_params)
      permitted_params[:photos]&.each do |photo|
        if @item
          if @item.persisted?
            @item.photos.attach(photo) unless photo.blank?
          else
            @item.photos.build(photo) unless photo.blank?
          end
        end
      end
      permitted_params.delete(:photos)
    end

    def convert_dimensions(permitted_params)
      %i[length width height].each do |dimension|
        if permitted_params[dimension].present?
          permitted_params[dimension] = permitted_params[dimension].gsub(',', '.').to_f * 10
        end
      end
    end
  end
end
