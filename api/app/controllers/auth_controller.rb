class AuthController < ApplicationController
    # Skip auth check on login
    skip_before_action :authorize_request, only: :login

    # POST /login
    def login
        # Find user by email
        user = User.find_by(email: params[:email])
        # `authenticate` comes from `has_secure_password`
        if user&.authenticate(params[:password])
        token = JsonWebToken.encode(user_id: user.id)
        render json: {
            user:  user_json(user),
            token: token
        }, status: :ok
        else
        render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
    end

    private

    def user_json(user)
        user.as_json(only: [:id, :name, :email, :image])
    end
end