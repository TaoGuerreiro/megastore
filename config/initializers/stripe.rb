require Rails.root.join("app/services/stripe_checkout_session_service.rb")


Rails.configuration.stripe = {
  publishable_key: Rails.application.credentials.stripe_publishable_key,
  secret_key:      Rails.application.credentials.stripe_secret_key,
  signing_secret:  Rails.application.credentials.stripe_webhook_secret_key
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
StripeEvent.signing_secret = Rails.configuration.stripe[:signing_secret]

StripeEvent.configure do |events|
  events.subscribe 'checkout.session.completed', StripeCheckoutSessionService.new
end
