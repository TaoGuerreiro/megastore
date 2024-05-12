# frozen_string_literal: true

unless File.read('Gemfile').match?(/gem ['"]cuprite/)
  gem 'cuprite', group: 'test'

  Bundler.with_unbundled_env do
    run 'bundle install'
  end
end

unless File.read('Gemfile').match?(/gem ['"]rspec-rails/)
  gem 'rspec-rails', groups: %w[development test]
  rails_command 'generate rspec:install'

  Bundler.with_unbundled_env do
    run 'bundle install'
  end
end

create_file 'spec/system/support/better_rails_system_tests.rb' do
  <<~'RUBY'
    # frozen_string_literal: true

    module BetterRailsSystemTests
      # Use our `Capybara.save_path` to store screenshots with other capybara artifacts
      # (Rails screenshots path is not configurable https://github.com/rails/rails/blob/49baf092439fc74fc3377b12e3334c3dd9d0752f/actionpack/lib/action_dispatch/system_testing/test_helpers/screenshot_helper.rb#L79)
      def absolute_image_path
        Rails.root.join("#{Capybara.save_path}/screenshots/#{image_name}.png")
      end

      # Make failure screenshots compatible with multi-session setup.
      # That's where we use Capybara.last_used_session introduced before.
      def take_screenshot
        return super unless Capybara.last_used_session

        Capybara.using_session(Capybara.last_used_session) { super }
      end
    end

    RSpec.configure do |config|
      config.include BetterRailsSystemTests, type: :system
      config.include Rails.application.routes.url_helpers

      # Make urls in mailers contain the correct server host.
      # It's required for testing links in emails (e.g., via capybara-email).
      config.around(:each, type: :system) do |ex|
        was_host = Rails.application.default_url_options[:host]
        Rails.application.default_url_options[:host] = Capybara.server_host
        ex.run
        Rails.application.default_url_options[:host] = was_host
      end
    end
  RUBY
end

create_file 'spec/system/support/capybara_setup.rb' do
  <<~'RUBY'
    # frozen_string_literal: true

    # Usually, especially when using Selenium, developers tend to increase the max wait time.
    # With Cuprite, there is no need for that.
    # We use a Capybara default value here explicitly.
    Capybara.default_max_wait_time = 2

    # Normalize whitespaces when using `has_text?` and similar matchers,
    # i.e., ignore newlines, trailing spaces, etc.
    # That makes tests less dependent on slightly UI changes.
    Capybara.default_normalize_ws = true

    # Where to store system tests artifacts (e.g. screenshots, downloaded files, etc.).
    # It could be useful to be able to configure this path from the outside (e.g., on CI).
    Capybara.save_path = ENV.fetch('CAPYBARA_ARTIFACTS', './tmp/capybara')

    # The Capybara.using_session allows you to manipulate a different browser session, and thus,
    # multiple independent sessions within a single test scenario. That’s especially useful for
    # testing real-time features, e.g., something with WebSocket.
    #
    # This patch tracks the name of the last session used. We’re going to use this information to
    # support taking failure screenshots in multi-session tests.
    Capybara.singleton_class.prepend(Module.new do
      attr_accessor :last_used_session

      def using_session(name, &block)
        self.last_used_session = name
        super
      ensure
        self.last_used_session = nil
      end
    end)
  RUBY
end

create_file 'spec/system/support/cuprite_setup.rb' do
  <<~'RUBY'
    # frozen_string_literal: true

    # First, load Cuprite Capybara integration
    require 'capybara/cuprite'

    # Configure Capybara to use :cuprite driver by default
    Capybara.default_driver = Capybara.javascript_driver = :cuprite

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
          process_timeout: 10,
          # Enable debugging capabilities
          inspector: ENV['INSPECTOR'],
          # Allow running Chrome in a headful mode by setting HEADLESS env
          # var to a falsey value
          headless: !ENV['HEADLESS'].in?(%w[n 0 no false])
        }
      end
    end
  RUBY
end

create_file 'spec/system/support/precompile_assets.rb' do
  <<~"RUBY"
    # frozen_string_literal: true

    require 'rake'

    #{Rails.application.class}.load_tasks

    RSpec.configure do |config|
      # Skip assets precompilcation if we exclude system specs.
      # For example, you can run all non-system tests via the following command:
      #
      #    rspec --tag ~type:system
      #
      # In this case, we don't need to precompile assets.
      next if config.filter.opposite.rules[:type] == 'system' || config.exclude_pattern.match?(%r{spec/system})

      config.before(:suite) do
        Rake::Task['assets:precompile'].invoke
      end
    end
  RUBY
end

create_file 'spec/system_helper.rb' do
  <<~'RUBY'
    # frozen_string_literal: true

    # https://evilmartians.com/chronicles/system-of-a-test-setting-up-end-to-end-rails-testing

    # Load general RSpec Rails configuration
    require 'rails_helper'

    # Load configuration files and helpers
    Dir[File.join(__dir__, 'system/support/**/*.rb')].sort.each { |file| require file }
  RUBY
end

create_file 'spec/system/cuprite_driver_spec.rb' do
  <<~'RUBY'
    require 'system_helper'

    RSpec.describe 'Cuprite driver', type: :system do
      it 'works' do
        visit 'https://example.com:443'
        sleep 3
        within('h1') do
          expect(page).to have_content('Example Domain')
        end
      end
    end
  RUBY
end

run 'HEADLESS=false bundle exec rspec spec/system/cuprite_driver_spec.rb'

run 'rm -f spec/system/cuprite_driver_spec.rb' if yes?(
  'We used spec/system/cuprite_driver_spec.rb just for testing the new setup. '\
  'Would you like to delete it?'
)
