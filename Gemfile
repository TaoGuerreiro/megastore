source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"
gem "rails", "~> 7.0.8"

gem "bootsnap", require: false
gem "aws-sdk-s3", require: false
gem "cssbundling-rails"
gem "devise_invitable"
gem "devise-i18n"
gem "devise"
gem "enumerize"
gem "image_processing", "~> 1.2"
gem "mini_magick"


gem "jbuilder"
gem "jsbundling-rails"
gem "money-rails", "~> 1.13"
gem "pg", "~> 1.1"
gem "postmark-rails"
gem "puma", "~> 5.0"
gem 'rails-i18n', '~> 7.0.0'
gem "redis", "~> 4.0"
gem "sidekiq-failures", "~> 1.0"
gem "sidekiq"
gem "simple_form", "~> 5.2"
gem "slim-rails"
gem "sprockets-rails"
gem "stimulus-rails"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem 'stripe'
gem 'stripe_event'
gem "view_component", "~> 3.4.0"

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "pry-byebug"
  gem "faker"
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
