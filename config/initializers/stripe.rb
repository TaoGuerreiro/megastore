# frozen_string_literal: true

return if Rails.env.test?

Rails.configuration.stripe = {
  publishable_key: Rails.application.credentials.stripe.send(Rails.env).stripe_publishable_key,
  secret_key: Rails.application.credentials.stripe.send(Rails.env).stripe_secret_key,
  signing_secret: Rails.application.credentials.stripe.send(Rails.env).stripe_webhook_secret_key
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
