# Test helper for Rails tests
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require 'json'

class ActiveSupport::TestCase
  # Run tests in parallel using available processors
  parallelize(workers: :number_of_processors)

  # Use transactional tests for database consistency
  self.use_transactional_tests = true

  # Parse JSON response body into a Hash
  def json_response
    JSON.parse(response.body)
  end

  # Get a valid JWT token by signing up (or logging in) in tests
  def get_jwt_for_user(email:, password:)
    user = User.find_by(email: email)
    unless user
      user = User.create!(name: "Test User", email: email, password: password, password_confirmation: password)
    end
    post '/login',
        params: { email: email, password: password },
        as: :json
    assert_response :success
    json_response['token']
  end
end
