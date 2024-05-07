# frozen_string_literal: true

module Admin
  class PhotosController < AdminController
    def remove_photo
      @item = Item.find(params[:id])
      # authorize! @item FIXME
      @photo = @item.photos.attachments.find(params[:photo_id])
      @photo.purge

      respond_to do |format|
        format.html { redirect_to edit_admin_item_path(@item), notice: t(".success") }
        format.turbo_stream
      end
    end
  end
end
