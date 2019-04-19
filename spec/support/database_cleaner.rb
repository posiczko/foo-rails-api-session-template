RSpec.configure do |config|
  # Wrap tests in transactions to speed things along in AR based tests.
  # Note that since we are in API mode, we do not have JS browser driver
  # connecting on a separate connection in the spec. If we did, that separate
  # connection to the db would not see data inside uncommited transaction.
  config.use_transactional_fixtures = true

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
