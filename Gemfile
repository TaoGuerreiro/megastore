source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"
gem "rails", "~> 7.0.8"

gem "bootsnap", require: false
gem "cssbundling-rails"
gem "jbuilder"
gem "jsbundling-rails"
gem "pg", "~> 1.1"
gem "puma", "~> 5.0"
gem "redis", "~> 4.0"
gem "sprockets-rails"
gem "stimulus-rails"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "slim-rails"
gem "view_component", "~> 3.4.0"
gem "enumerize"
gem "sidekiq"
gem "sidekiq-failures", "~> 1.0"
gem "simple_form", "~> 5.2"
gem "devise"
gem "devise-i18n"
gem "devise_invitable"

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "pry-byebug"
  gem "pry-rails"
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
