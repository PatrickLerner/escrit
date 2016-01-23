require 'simplecov'

SimpleCov.start do
  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Helpers", "app/helpers"
  add_group "Other", "db"
  add_filter '/spec/'
end

RSpec.configure do |config|
  config.before(:suite) { FactoryGirl.reload }
  config.include FactoryGirl::Syntax::Methods
  
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
