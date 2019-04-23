module Authorization
  extend ActiveSupport::Concern

  rescue_from ActionController::InvalidAuthenticityToken do |e|
    render_error_from(message: "Invalid token",
                      code: "unauthorized",
                      status: :unauthorized)
  end

  # @return [User]
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end
