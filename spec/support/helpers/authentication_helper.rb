#
# Assumes existence of session_url which can be POSTed to
# with credentials.
#
module AuthenticationHelper
  def sign_in_as(user)
    credentials = {
      session: {
        username: user.email,
        password: "secret",
      },
    }

    post session_url, params: credentials
    expect(response).to have_http_status(:created)
    expect(session[:user_id]).to eql user.id
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :request
  config.include AuthenticationHelper, type: :feature
end
