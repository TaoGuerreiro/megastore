# frozen_string_literal: true

module Admin
  class ItemsController < AdminController
    before_action :set_specifications, only: %i[new edit update]
    before_action :set_item, only: %i[edit update destroy]
    before_action lambda {
      resize_before_save(item_params[:photos], 300, 300)
    }, only: [:create]


    def index
      set_counts
      @collections = authorized_scope(Collection.all)

      if params[:search].present?
        search_items
        respond_to { |format| format.turbo_stream }
      else
        @items = filterable(Item, authorized_scope(Item.includes(:photos, :category)))
        @pagy, @items = pagy(@items)
      end

      authorize! @items
    end

    def new
      @item = Item.new
      authorize! @item
    end

    def edit; end

    def create
      @item = Item.new(item_params.except(:photos))
      authorize! @item

      @item.store = Store.find_by(domain: request.domain)

      if @item.save
        manage_photos(item_params)
        redirect_to admin_items_path, notice: t(".success")
      else
        render :new, status: :unprocessable_entity, notice: t(".error")
      end
    end

    def update
      if @item.update(item_params)
        redirect_to admin_items_path, notice: t(".success")
      else
        render :edit, status: :unprocessable_entity, notice: t(".error")
      end
    end

    def destroy
      if @item.destroy
        respond_to do |format|
          format.html { redirect_to admin_items_path, notice: t(".success") }
        end
      else
        respond_to do |format|
          format.html { redirect_to admin_items_path, notice: t(".error") }
        end
      end
      format.turbo_stream
    end

    private

    def resize_before_save(image_param, width, height)
      return unless image_param

      begin
        ImageProcessing::MiniMagick
          .source(image_param)
          .resize_to_fit(width, height)
          .call(destination: image_param.tempfile.path)
      rescue StandardError => _e
        # Do nothing. If this is catching, it probably means the
        # file type is incorrect, which can be caught later by
        # model validations.
      end
    end


    def set_item
      @item = Item.find(params[:id])
      authorize! @item
    end

    def set_specifications
      @specifications = authorized_scope(Specification.all)
    end

    def set_counts
      @active_items_count = Item.where(store: Current.store, status: :active).count
      @offline_items_count = Item.where(store: Current.store, status: :offline).count
      @archived_items_count = Item.where(store: Current.store, status: :archived).count
    end

    def search_items
      @items = Item.where(store: Current.store).search_by_name_and_description(params[:search])
      @pagy, @items = pagy(@items)
    end

    def item_params
      params.require(:item).permit(:name, :description, :price, :image, :stock, :length, :width, :height, :weight,
                                   :category_id, :format, :collection_id, :active, :status,
                                   photos: [], shipping_method_ids: [], specification_ids: []).tap do |permitted_params|
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
      permitted_params[:photos]&.each do |photo|
        if @item
          if @item.persisted?
            @item.photos.attach(photo) if photo.present?
          elsif photo.present?
            @item.photos.build(photo)
          end
        end
      end
      permitted_params.delete(:photos)
    end

    def convert_dimensions(permitted_params)
      %i[length width height].each do |dimension|
        if permitted_params[dimension].present?
          permitted_params[dimension] = permitted_params[dimension].gsub(",", ".").to_f * 10
        end
      end
    end
  end
end
