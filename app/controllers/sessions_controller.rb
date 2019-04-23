class SessionsController < ApplicationController
  def create
    if @user = User.authenticate(session_params[:username],
                                 session_params[:password])
      session[:user_id] = @user.id
      render_jsonapi_from(serializer_for: :session, object: @user, status: :created)
    else
      render_error_from(message: "Invalid credentials", code: "unauthorized", status: :unauthorized)
    end
  end

  def destroy
    session[:user_id] = nil
    head :ok
  end

  private

  def session_params
    params.require(:session).permit(:username, :password)
  end
end
