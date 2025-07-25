# frozen_string_literal: true

# First, load Cuprite Capybara integration
require 'capybara/cuprite'

# Configure Capybara to use :cuprite driver by default
Capybara.default_driver = Capybara.javascript_driver = :cuprite
Capybara.default_max_wait_time = 10
module CupriteHelpers
  # Drop #pause anywhere in a test to stop the execution.
  # Useful when you want to checkout the contents of a web page in the middle of a test
  # running in a headful mode.
  def pause
    page.driver.pause
  end

  # Drop #debug anywhere in a test to open a Chrome inspector and pause the execution
  def debug(*args)
    page.driver.debug(*args)
  end
end

RSpec.configure do |config|
  config.include CupriteHelpers, type: :system

  # Make sure this hook runs before others
  config.prepend_before(:each, type: :system) do
    # Use JS driver always
    driven_by :cuprite, using: :chrome, options: {
      window_size: [1200, 800],
      # See additional options for Dockerized environment in the respective section of this article
      browser_options: {},
      # Increase Chrome startup wait time (required for stable CI builds)
      process_timeout: 20,
      # Enable debugging capabilities
      inspector: ENV['INSPECTOR'],
      # Allow running Chrome in a headful mode by setting HEADLESS env
      # var to a falsey value
      headless: false
    }
  end
end
