# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'
gem 'rails', '~> 7.0.8'

gem 'aws-sdk-s3', require: false
gem 'bootsnap', require: false
gem 'cssbundling-rails'
gem 'devise'
gem 'devise-i18n'
gem 'devise_invitable'
gem 'enumerize'
gem 'image_processing', '~> 1.2'
gem 'mini_magick'
gem 'action_policy'
gem 'activerecord-session_store'
gem 'country_select'
gem 'httparty'
gem 'jbuilder'
gem 'jsbundling-rails'
gem "mechanize"
gem 'money-rails', '~> 1.13'
gem 'pagy', '~> 7.0'
gem 'pg', '~> 1.1'
gem 'pg_search'
gem 'postmark-rails'
gem 'puma', '~> 5.0'
gem 'rails-i18n', '~> 7.0.0'
gem 'redis', '~> 4.0'
gem 'sidekiq'
gem 'sidekiq-failures', '~> 1.0'
gem 'simple_form', '~> 5.2'
gem 'slim-rails'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'stripe'
gem 'stripe_event'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'view_component', '~> 3.4.0'

group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'faker'
  gem 'pry-byebug'
end

group :development do
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
end
