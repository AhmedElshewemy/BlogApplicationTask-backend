class ApplicationController < ActionController::API
  before_action :authorize_request

  private

   # Fetches the 'Bearer <token>' header, decodes it, and finds the current user
  def authorize_request
  header = request.headers['Authorization']
  header = header.split(' ').last if header.present?
  decoded = JsonWebToken.decode(header)
  @current_user = User.find_by(id: decoded[:user_id]) if decoded

  return if @current_user

  render json: { error: 'Not Authorized' }, status: :unauthorized
  end
end
