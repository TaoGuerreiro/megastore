# frozen_string_literal: true

require_relative "boot"

require "rails/all"
require "factory_bot_rails"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Megastore
  class Application < Rails::Application
    config.assets.paths << Rails.root.join("app/assets/fonts")

    config.load_defaults 7.0

    config.generators do |generate|
      generate.helper false
      generate.template_engine :slim
      generate.test_framework :rspec, fixture: true
      generate.fixture_replacement :factory_bot, dir: "spec/factories"
    end

    config.autoload_paths << Rails.root.join("app/services/*.rb")
    config.time_zone = "Europe/Paris"
    config.i18n.default_locale = :fr
    config.i18n.fallbacks = [:en]
    config.i18n.load_path += Dir[Rails.root.join("config/locales/**/*.{rb,yml}")]

    config.active_job.queue_adapter = :sidekiq

    config.autoload_paths += Dir[Rails.root.join("lib/filterable_lib")]
    config.i18n.load_path += Dir[Rails.root.join("lib/filterable_lib/locales/**/*.yml")]

    config.autoload_lib(ignore: %w(assets tasks))

  end
end
