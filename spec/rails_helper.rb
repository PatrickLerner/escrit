ENV['RAILS_ENV'] ||= 'test'
if ENV['coverage']
  require 'simplecov'
  SimpleCov.start do
    add_group 'Controllers', 'app/controllers'
    add_group 'Helpers', 'app/helpers'
    add_group 'Models', 'app/models'
    add_group 'Other', ['db', 'lib']
    add_filter '/spec/'
    add_filter '/config/'
  end

  SimpleCov.at_exit do
    SimpleCov.result.format!
    require 'launchy'
    Launchy.open('coverage/index.html')
  end
end
require File.expand_path('../../config/environment', __FILE__)
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'devise'
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

# core extensions
Dir[File.join(Rails.root, 'lib', 'core_extensions', '*.rb')].each {|l| require l }

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include Warden::Test::Helpers

  truncation_options = { except: %w[languages compliments] }

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    Warden.test_mode!
  end

  config.after(:each) do
    Warden.test_reset!
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation, truncation_options
  end

  config.before(:each) do
    DatabaseCleaner.start
    Rails.application.load_seed
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after do |example|
    if example.metadata[:type] == :feature and example.exception.present?
      save_and_open_page
    end
  end

  config.include Devise::TestHelpers, type: :controller
  config.include Warden::Test::Helpers
  config.extend FeatureMacros, type: :feature

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true

  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!

  # config.filter_rails_from_backtrace!
end
