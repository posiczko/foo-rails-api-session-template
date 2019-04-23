class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection
  include Response
  include ErrorHandler
  include Authorization

  before_action :set_csrf_cookie

  private

  def set_csrf_cookie
    cookies["CSRF-TOKEN"] = form_authenticity_token
  end

  def authenticate_user
    unless current_user
      render_error_from(message: "Invalid credentials",
        code: "unauthorized",
        status: :unauthorized)
    end
  end
end
