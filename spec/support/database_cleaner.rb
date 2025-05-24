# frozen_string_literal: true

RSpec.configure do |config|

  # config.before(:each, type: :feature) do
  #   DatabaseCleaner.strategy = :truncation
  # end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
    DatabaseCleaner.strategy = :transaction
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
