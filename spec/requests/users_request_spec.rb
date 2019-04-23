require "rails_helper"

RSpec.describe "BadRequests", type: :request do
  describe "POST :create" do
    it "creates an account" do
      # setup
      valid_params = {
        user: {
          username: "test",
          password: "secret",
        },
      }

      # excercise/test
      expect { post(users_url, params: valid_params) }.to change(User, :count)
      expect(response).to be_successful
      expect(response).to have_http_status(:created)
      expect(json[:data][:attributes]).to include(username: valid_params[:user][:username])
    end

    it "fails when params are missing" do
      valid_params = {
        user: {
          username: "",
          password: "",
        },
      }

      expect { post(users_url, params: valid_params) }.not_to change(User, :count)
      expect(response).not_to be_successful
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors].keys).to contain_exactly(:username, :password)
    end

    it "fails when username has already been taken" do
      user = create(:user)
      invalid_params = {
        user: {
          username: user.username,
          password: "secret",
        },
      }
      expect { post(users_url, params: invalid_params) }.not_to change(User, :count)
      expect(response).not_to be_successful
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors].keys).to contain_exactly(:username)
    end
  end
end
