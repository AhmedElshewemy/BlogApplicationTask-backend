# api/test/integration/posts_test.rb
require 'test_helper'

class PostsTest < ActionDispatch::IntegrationTest
  setup do
    # Create two users: author and another_user
    @author =
      User.create!(
        name: "Author One",
        email: "author@test.com",
        password: "pass123",
        password_confirmation: "pass123"
      )
    @other_user =
      User.create!(
        name: "Not Author",
        email: "not_author@test.com",
        password: "pass456",
        password_confirmation: "pass456"
      )

    # Obtain JWT tokens
    @auth_token_author = get_jwt_for_user(email: "author@test.com", password: "pass123")
    @auth_token_other  = get_jwt_for_user(email: "not_author@test.com", password: "pass456")

    # Create a sample Post by the author (with tags)
    @post = @author.posts.create!(
      title: "Existing Post",
      body: "Body of the post",
      tags: [Tag.find_or_create_by(name: "rails")]
    )
  end

  test "GET /posts (requires auth)" do
    get '/posts', as: :json
    assert_response :unauthorized
    assert_equal "Not Authorized", json_response['error']

    # With valid token
    get '/posts', headers: { "Authorization" => "Bearer #{@auth_token_author}" }, as: :json
    assert_response :success
    assert json_response.is_a?(Array)
    # Should include the existing post
    assert json_response.any? { |p| p['id'] == @post.id }
  end

  test "POST /posts: create with valid data (success)" do
    post '/posts',
         headers: { "Authorization" => "Bearer #{@auth_token_author}" },
         params: {
           post: {
             title: "New Post Title",
             body: "Some interesting content",
             tags: ["ruby", "docker"]
           }
         },
         as: :json

    assert_response :created
    body = json_response
    assert_equal "New Post Title", body['title']
    assert body['tags'].length >= 1
    # Verify scheduled job exists in Redis (optional if you want to inspect Sidekiq)
  end

  test "POST /posts: missing tags (failure)" do
    post '/posts',
         headers: { "Authorization" => "Bearer #{@auth_token_author}" },
         params: {
           post: {
             title: "No Tags Post",
             body: "Content but no tags",
             tags: []
           }
         },
         as: :json

    assert_response :unprocessable_entity
    body = json_response
    assert body['errors'].any? { |err| err.downcase.include?("tags must have at least one") }
  end

  test "PUT /posts/:id by non-owner (forbidden)" do
    put "/posts/#{@post.id}",
        headers: { "Authorization" => "Bearer #{@auth_token_other}" },
        params: {
          post: {
            title: "Hacked Title"
          }
        },
        as: :json

    assert_response :forbidden
    assert_equal "Forbidden: not post owner", json_response['error']
  end

  test "PUT /posts/:id by owner (success)" do
    put "/posts/#{@post.id}",
        headers: { "Authorization" => "Bearer #{@auth_token_author}" },
        params: {
          post: {
            title: "Updated Title",
            tags: ["rails", "api"]
          }
        },
        as: :json

    assert_response :success
    body = json_response
    assert_equal "Updated Title", body['title']
    assert body['tags'].any? { |t| t['name'] == "api" }
  end

  test "DELETE /posts/:id by non-owner (forbidden)" do
    delete "/posts/#{@post.id}",
           headers: { "Authorization" => "Bearer #{@auth_token_other}" },
           as: :json

    assert_response :forbidden
    assert_equal "Forbidden: not post owner", json_response['error']
  end

  test "DELETE /posts/:id by owner (success)" do
    delete "/posts/#{@post.id}",
           headers: { "Authorization" => "Bearer #{@auth_token_author}" },
           as: :json

    assert_response :no_content
    # Confirm the post is gone
    assert_nil Post.find_by(id: @post.id)
  end
end