puts "[DEBUG] LOADED test_helper: #{__FILE__}"
puts "[DEBUG] LOADED test_helper: #{__FILE__}"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require 'json'

# module ActiveSupport
#   class TestCase
    class ActiveSupport::TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    #fixtures :all

    # Add more helper methods to be used by all tests here...

   # self.use_transactional_fixtures = true
    self.use_transactional_tests = true
  # Parse JSON response body into a Hash
    def json_response
      JSON.parse(response.body)
    end

    # Get a valid JWT token by signing up (or logging in) in tests
    def get_jwt_for_user(email:, password:)
      # If the user doesn’t exist yet, create them
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
