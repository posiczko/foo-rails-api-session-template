    rails new myapp --api -d postgresql \
      --skip-test \
      --skip-action-cable \
      --skip-turbolinks \
      --skip-active-storage \
      --template https://raw.githubusercontent.com/posiczko/rails-api-sessions/master/template.rb

## RSpec For Testing

* FactoryBot is included and linted before suite run.

* RSpec uses database_cleaner for testing with tests wrapped in the transaction
  for extra giddy-up factor.
  
* Email spec is included with [matchers and helpers](https://github.com/bmabey/email-spec#rspec)

* Time helpers are included and enabled. [See](http://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html)

* VCR and Mock are included and enabled for interaction with outside world. 
  [See](https://relishapp.com/vcr/vcr/docs)
  
* Authentication helper is included for features and requests 
  which assumes `session_path` exists. See `spec/support/authentication_helper.rb`.
  
* Non-memoizing JSON helper which parses the body is included and enabled.
