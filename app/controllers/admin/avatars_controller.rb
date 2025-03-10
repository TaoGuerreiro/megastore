# frozen_string_literal: true

module Admin
  class AvatarsController < AdminController
    def remove_avatar
      @author = Author.find(params[:id])
      @avatar = @author.avatar
      @avatar.purge

      respond_to do |format|
        format.html { redirect_to edit_admin_author_path(@author), notice: t(".success") }
        format.turbo_stream
      end
    end
  end
end
