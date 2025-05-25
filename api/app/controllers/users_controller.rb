class UsersController < ApplicationController
  # Skip auth check on signup
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

  # Strong params: :name, :email, :password, :password_confirmation, :image
  def user_params
    params.permit(:name, :email, :password, :password_confirmation, :image)
  end

  # Sanitize what you send back (no password_digest!)
  def user_json(user)
    user.as_json(only: [:id, :name, :email, :image])
  end
end
