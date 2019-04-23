require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "POST :create with valid crendentials" do
    it "returns valid user" do
      user = create(:user)

      valid_credentials = {
        session: {
          username: user.username,
          password: 'secret'
        }
      }

      post session_url, params: valid_credentials
      expect(response).to be_successful
      expect(response).to have_http_status(:created)
      expect(json[:data][:attributes]).to include({username: user.username})
    end
  end

  describe "POST :create with invalid credentials" do
    it "fails" do
      user = create(:user)

      invalid_credentials = {
        session: {
          username: user.username,
          password: 'wrong-password'
        }
      }

      post session_url, params: invalid_credentials
      expect(response).not_to be_successful
      expect(response).to have_http_status(:unauthorized)
      expect(request.session[:user_id]).to be_nil
      expect(response).to have_api_error(status: 401, code: "unauthorized", message: "Invalid credentials")
    end
  end

  describe "DELETE :destroy" do
    it "removes session" do
      user = create(:user)
      delete session_url

      expect(response).to be_successful
      expect(request.session[:user_id]).to be_nil
    end
  end
end
