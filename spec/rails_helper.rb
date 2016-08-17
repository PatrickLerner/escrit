if ENV['coverage']
  require 'simplecov'
  SimpleCov.start do
    add_group 'Controllers', 'app/controllers'
    add_group 'Helpers', 'app/helpers'
    add_group 'Models', 'app/models'
    add_group 'Other', 'lib'
    add_filter '/spec/'
    add_filter '/db/'
    add_filter '/config/'
    track_files '{app,lib}/**/*.rb'
  end

  SimpleCov.at_exit do
    SimpleCov.result.format!
    require 'launchy'
    Launchy.open('coverage/index.html')
  end
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
if Rails.env.production?
  abort('The Rails environment is running in production mode!')
end

require 'spec_helper'
require 'rspec/rails'

ActiveRecord::Migration.maintain_test_schema!

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

DBQueryMatchers.configure do |config|
  config.schemaless = true
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.before(:suite) { FactoryGirl.reload }
  config.include FactoryGirl::Syntax::Methods
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Warden::Test::Helpers
  config.extend ControllerMacros, type: :controller

  truncation_options = { except: %w(languages compliments) }

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
    if example.metadata[:type] == :feature && example.exception.present?
      save_and_open_page
    end
  end
end
