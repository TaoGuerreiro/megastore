# frozen_string_literal: true

module Queen
  class UsersController < QueenController
    def index
      @users = User.all
    end

    def new
      @user = User.new
      @user.build_store
    end

    def edit
      @user = User.find(params[:id])
    end

    def create
      @user = User.new(user_params)
      @user.password = Devise.friendly_token.first(8)
      @user.store.admin = @user
      @user.store.stripe_subscription_id = "DEV____#{SecureRandom.uuid}"

      if @user.save
        redirect_to queen_users_path, status: :see_other, notice: t(".success")
      else
        render :new, status: :unprocessable_entity, notice: t(".error")
      end
    end

    def update
      @user = User.find(params[:id])

      if @user.update(user_params)
        redirect_to queen_users_path, status: :see_other, notice: t(".success")
      else
        render :edit, status: :unprocessable_entity, notice: t(".error")
      end
    end

    def destroy
      @user = User.find(params[:id])
      @user.destroy
      redirect_to queen_users_path, status: :see_other, notice: t(".success")
    end

    def set_localhost
      @user = User.find(params[:id])
      Store.update_all(domain: nil)
      @user.store.update(domain: "localhost")
      redirect_to queen_users_path, status: :see_other, notice: t(".success")
    end

    private

    def user_params
      params.require(:user).permit(
        :first_name,
        :last_name,
        :email,
        :phone,
        :role,
        store_attributes: [
          :id,
          :name,
          :address,
          :city,
          :postal_code,
          :country,
          :domain,
          :slug,
          :about,
          :mail_body,
          :holiday,
          :holiday_sentence,
          :display_stock,
          :meta_title,
          :meta_description,
          :meta_image,
          :instagram_url,
          :facebook_url,
          :postmark_key,
          :sendcloud_private_key,
          :sendcloud_public_key,
          :rates,
          :stripe_account_id,
          :charges_enable,
          :payouts_enable,
          :details_submitted,
          :stripe_subscription_id,
          :subscription_status,
          :stripe_checkout_session_id
        ]
      )
    end
  end
end
