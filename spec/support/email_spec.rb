require "action_mailer"
require "email_spec"
#
# See:
#
# https://github.com/bmabey/email-spec#rspec
# https://github.com/bmabey/email-spec#rspec-matchers
# http://www.rubydoc.info/gems/email_spec/EmailSpec/Helpers
# http://www.rubydoc.info/gems/email_spec/EmailSpec/Matchers
#
RSpec.configure do |config|
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers

  config.before(:each) do
    reset_mailer # Clears out ActionMailer::Base.deliveries
  end
end
