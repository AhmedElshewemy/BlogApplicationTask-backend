class UsersController < ApplicationController
  # Skip authentication for signup
  skip_before_action :authorize_request, only: :create

  # POST /signup
  def create
    user = User.new(user_params)
    if user.save
      token = JsonWebToken.encode(user_id: user.id)
      render json: {
        user:  user_json(user),
        token: token
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # Only allow permitted user attributes
  def user_params
    params.permit(:name, :email, :password, :password_confirmation, :image)
  end

  # Return user data without sensitive fields
  def user_json(user)
    user.as_json(only: [:id, :name, :email, :image])
  end
end
