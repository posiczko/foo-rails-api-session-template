class UsersController < ApplicationController
  # has_secure_password doesn't wrap password
  wrap_parameters :user, include: %i[username password]

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      # render status: :created
      render_jsonapi_from(serializer_for: :user,
                          object: @user,
                          status: :created)
    else
      render(json: { errors: @user.errors },
             status: :unprocessable_entity)
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :password)
  end
end
