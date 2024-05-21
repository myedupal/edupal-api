source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.8"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem "rack-cors"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mingw x64_mingw]

  gem 'rspec-rails'
  gem 'rswag-specs'

  # dummy data generator
  gem 'factory_bot_rails'
  gem 'faker'
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  # generates ERD diagram
  gem 'railroady'

  # open email in browser
  gem "letter_opener"

  # linter and syntax checking
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  # vulnerability scanning
  gem "brakeman", require: false
end

group :test do
  gem "bullet"
  gem "rspec-sidekiq"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem 'stripe-ruby-mock', git: 'https://github.com/stripe-ruby-mock/stripe-ruby-mock', require: 'stripe_mock'

  # only enable if it is necessary
  gem "sinatra"
  gem "webmock"
end

group :production do
  gem "cloudflare-rails"
  gem "elastic-apm"

  # drop-in replacement for websocket
  # gem "anycable-rails", "~> 1.1"
end

# authentication
gem 'devise'

# authorization
gem 'pundit'

# pagination
gem "pagy"

# database view
gem "scenic"

# background processing
gem "sidekiq"
gem "sidekiq-scheduler"

# handling currency
gem "money-rails"

# use interactor pattern for complex workflow
gem "interactor-rails"

# application settings
gem "rails-settings-cached"

# view layer of JSON API
gem "active_model_serializers"

# file upload & processing
gem "carrierwave", "~> 2.1"
gem "carrierwave-base64", "~> 2.8"
gem "file_validators", "~> 2.3"
gem "fog-aws", "~> 3.6"

# only needed for csv processing
# gem "smarter_csv", "~> 1.2"

# state machine
gem "aasm"

# geolocation gem
# gem "geocoder", "~> 1.6"

# PDF gems
# gem "wicked_pdf", "~> 2.1"
# gem 'wkhtmltopdf-binary', '~> 0.12.6.5'
# gem "combine_pdf", "~> 1.0"

# record tracking
# gem "paper_trail"

# for shorter id
gem "nanoid"

# env variables loading
gem "dotenv-rails"

# managing notifications
gem "noticed", "~> 1.6"

# payment processing
gem "stripe"

gem "razorpay"

gem "googleauth", "~> 1.11"

gem "progressbar", "~> 1.13"
