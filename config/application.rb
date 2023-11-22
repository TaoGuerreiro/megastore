require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Megastore
  class Application < Rails::Application
    Rails.application.config.active_record.encryption.primary_key = Rails.application.credentials.active_record_encryption[:primary_key]
    config.load_defaults 7.0

    config.generators do |generate|
      generate.helper false
      generate.template_engine :slim
    end

    config.autoload_paths << Rails.root.join('app/services/*.rb')
    config.time_zone = "Europe/Paris"
    config.i18n.default_locale = :fr
    config.i18n.fallbacks = [:en]
    config.i18n.load_path += Dir[Rails.root.join("config/locales/**/*.{rb,yml}")]

    config.active_job.queue_adapter = :sidekiq

    config.autoload_paths += Dir[Rails.root.join("lib/filterable_lib")]
    config.i18n.load_path += Dir[Rails.root.join("lib/filterable_lib/locales/**/*.yml")]
  end
end
