# frozen_string_literal: true

module Admin
  class ArchivesController < AdminController
    before_action :set_item, only: %i[archive unarchive]

    def archive
      @item.archive!

      redirect_to admin_items_path, notice: t(".success")
    end

    def unarchive
      @item.update(status: :offline)

      redirect_to admin_items_path, notice: t(".success")
    end

    private

    def set_item
      @item = Item.find(params[:id])
      authorize! @item
    end
  end
end
