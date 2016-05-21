source 'https://rubygems.org'

gem 'rails', '>= 5.0.0.rc1', '< 5.1'
gem 'pg'
gem 'puma', '~> 3.0'

gem 'coffee-rails'
gem 'sass-rails'
gem 'slim-rails'
gem 'uglifier'

gem 'attribute_normalizer'
gem 'cancancan'
gem 'devise', github: 'plataformatec/devise', branch: 'master'
gem 'jbuilder'
gem 'naturalsort', require: 'natural_sort_kernel'
gem 'paperclip'
gem 'searchkick'
gem 'will_paginate'

gem 'angularjs-rails'
gem 'angular-rails-templates'
source 'https://rails-assets.org' do
  gem 'rails-assets-angular-devise'
end

gem 'audiojs'
gem 'bourbon'
gem 'font-awesome-rails'
gem 'lightbox2-rails'
gem 'neat'

group :development, :test do
  gem 'byebug'
  gem 'factory_girl_rails'
  gem 'faker'
  rs = %w(rspec-core rspec-expectations rspec-mocks rspec-rails rspec-support)
  rs.each do |lib|
    gem lib, git: "https://github.com/rspec/#{lib}.git", branch: 'master'
  end
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'poltergeist'
  gem 'shoulda'
  gem 'simplecov', require: false
end

group :development do
  gem 'letter_opener'
  gem 'quiet_assets'
  gem 'seed_dump'
  gem 'spring'
  gem 'web-console'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
