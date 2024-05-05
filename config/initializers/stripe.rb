# frozen_string_literal: true

Rails.configuration.stripe = {
  publishable_key: Rails.application.credentials.stripe.public_send(Rails.env).stripe_publishable_key,
  secret_key: Rails.application.credentials.stripe.public_send(Rails.env).stripe_secret_key,
  signing_secret: Rails.application.credentials.stripe.public_send(Rails.env).stripe_webhook_secret_key
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
