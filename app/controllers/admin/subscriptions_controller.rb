module Admin
  class SubscriptionsController < AdminController
    def create
      @store = Current.store

      session = Stripe::Checkout::Session.create(
        customer: current_user.stripe_customer_id,
        mode: 'subscription',
        line_items: [
          quantity: 1,
          price_data: {
            currency: 'eur',
            unit_amount: 2000,
            product_data: {
              name: 'Abonnement mensuel',
            },
            recurring: {
              interval: 'month'
            },
          }
        ],
        success_url: admin_store_url(@store) + '?session_id={CHECKOUT_SESSION_ID}',
        cancel_url: new_admin_onboarding_url
      )

      @store.update!(stripe_checkout_session_id: session.id)

      redirect_to session.url, allow_other_host: true
    end

    def destroy
      @store = Current.store

      customer_portal = Stripe::BillingPortal::Session.create({
        customer: current_user.stripe_customer_id,
        return_url: admin_store_url(@store)
      })

      redirect_to customer_portal.url, allow_other_host: true
    end
  end
end
