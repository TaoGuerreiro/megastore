module Admin
  class AccountsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_user

    layout "admin"

    def show; end

    def edit; end

    def update
      if @user.update(user_params)
        redirect_to admin_account_path, notice: "Account updated successfully"
      else
        render :edit, status: :unprocessable_entity, notice: "Account could not be updated"
      end
    end

    private

    def set_user
      @user = current_user
    end

    def user_params
      if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        params.require(:user).permit(
          :first_name,
          :last_name,
          :username,
          :email,
          :avatar,
        )
      else
        params.require(:user).permit(
          :first_name,
          :last_name,
          :username,
          :email,
          :avatar,
          :password,
          :password_confirmation
        )
      end
    end
  end
end
