# frozen_string_literal: true

class StripeConfigurationService
  def self.setup
    Rails.configuration.stripe = {
      publishable_key: Current.store.stripe_publishable_key,
      secret_key: Current.store.stripe_secret_key,
      signing_secret: Current.store.stripe_webhook_secret_key
    }

    Stripe.api_key = Rails.configuration.stripe[:secret_key]
    StripeEvent.signing_secret = Rails.configuration.stripe[:signing_secret]

    StripeEvent.configure do |events|
      events.subscribe 'checkout.session.completed', StripeCheckoutSessionService.new
    end
  end
end
