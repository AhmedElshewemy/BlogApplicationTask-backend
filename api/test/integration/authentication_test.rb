# api/test/integration/authentication_test.rb
require 'test_helper'

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "signup: successful" do
    post '/signup',
         params: {
           name: "Alice Test",
           email: "alice@test.com",
           password: "password123",
           password_confirmation: "password123",
           image: "https://example.com/avatar.png"
         },
         as: :json

    assert_response :created
    body = json_response

    # Expect a "user" object and a "token"
    assert body['user'].is_a?(Hash)
    assert body['user']['email'] == "alice@test.com"
    assert body['user'].key?('id')
    assert body['token'].present?
  end

  test "signup: missing password_confirmation (failure)" do
    post '/signup',
         params: {
           name: "Bob Test",
           email: "bob@test.com",
           password: "secret",
           # password_confirmation is missing
           image: "https://example.com/avatar2.png"
         },
         as: :json

    assert_response :unprocessable_entity
    body = json_response
    assert body['errors'].is_a?(Array)
    # Expect an error about password confirmation
    assert body['errors'].any? { |err| err.downcase.include?("password confirmation") }
  end

  test "login: successful" do
    # Ensure user exists
    User.create!(
      name: "Charlie Test",
      email: "charlie@test.com",
      password: "mypassword",
      password_confirmation: "mypassword"
    )

    post '/login',
         params: {
           email: "charlie@test.com",
           password: "mypassword"
         },
         as: :json

    assert_response :success
    body = json_response
    assert body['user']['email'] == "charlie@test.com"
    assert body['token'].present?
  end

  test "login: invalid credentials (failure)" do
    # No user with this email
    post '/login',
         params: {
           email: "nonexistent@test.com",
           password: "whatever"
         },
         as: :json

    assert_response :unauthorized
    body = json_response
    assert_equal "Invalid email or password", body['error']
  end
end
