module Queen
  class UsersController < QueenController
    def index
      @users = User.all
    end

    def edit
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])

      if @user.update(user_params)
        redirect_to queen_users_path, notice: 'User was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
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
