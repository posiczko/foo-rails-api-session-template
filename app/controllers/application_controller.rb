class ApplicationController < ApiController
  include ActionController::MimeResponds
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection
  include Concerns::ErrorHandler
  include Concerns::Response

  before_action :set_csrf_cookie

  # @return [User]
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def set_csrf_cookie
    cookies["CSRF-TOKEN"] = form_authenticity_token
  end
end
