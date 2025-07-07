# frozen_string_literal: true

module Admin
  class AccountsController < AdminController
    before_action :set_user

    def show; end

    def edit; end

    def update
      old_username = @user.instagram_username_was
      old_password = @user.instagram_password_was
      if @user.update(user_params)
        # raise
        if (@user.instagram_username.present? && @user.instagram_username != old_username) || @user.password != old_password
          InstagramUserIdJob.perform_async(
            "User",
            @user.id,
            @user.instagram_username,
            @user.instagram_password,
            @user.instagram_username
          )
        end
        redirect_to admin_account_path, notice: t(".success")
      else
        render :edit, status: :unprocessable_entity, notice: t(".error")
      end
    end

    private

    def set_user
      @user = current_user
      authorize! @user
    end

    def user_params
      if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        params.require(:user).permit(:first_name, :last_name, :username, :email, :avatar, :phone, :instagram_username,
                                     :instagram_password)
      else
        params.require(:user).permit(:first_name, :last_name, :username, :email,
                                     :avatar, :password, :password_confirmation, :phone, :instagram_username, :instagram_password)
      end
    end
  end
end
