module Admin
  class OnboardingsController < ApplicationController
    include Rails.application.routes.url_helpers

    def new; end

    def create
      default_url_options[:host] = "https://#{Current.store.domain}"

      account = Stripe::Account.create(
        type: "standard",
        country: Current.store.country,
        email: current_user.email,
        business_type: "individual",
        business_profile: {
          mcc: "5734",
          product_description: "Online marketplace",
          name: current_user.full_name,
          url: "https://www.lecheveublanc.fr",
        }
      )

      link = Stripe::AccountLink.create(
        account: account.id,
        refresh_url: admin_store_url(Current.store),
        return_url: new_admin_onboarding_url,
        type: "account_onboarding",
        collect: "eventually_due",
      )

      Current.store.update(stripe_account_id: account.id)

      redirect_to link.url, allow_other_host: true
    end
  end
end
