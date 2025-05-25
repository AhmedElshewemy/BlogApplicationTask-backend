# api/test/integration/comments_test.rb
require 'test_helper'

class CommentsTest < ActionDispatch::IntegrationTest
  setup do
    # Create two users: post owner and comment owner and another user
    @post_owner =
      User.create!(
        name: "Post Owner",
        email: "postowner@test.com",
        password: "ownerpass",
        password_confirmation: "ownerpass"
      )
    @comment_owner =
      User.create!(
        name: "Comment Owner",
        email: "commentowner@test.com",
        password: "commentpass",
        password_confirmation: "commentpass"
      )
    @other_user =
      User.create!(
        name: "Somebody Else",
        email: "someoneelse@test.com",
        password: "otherpass",
        password_confirmation: "otherpass"
      )

    # Tokens for each
    @token_post_owner   = get_jwt_for_user(email: "postowner@test.com", password: "ownerpass")
    @token_comment_owner = get_jwt_for_user(email: "commentowner@test.com", password: "commentpass")
    @token_other         = get_jwt_for_user(email: "someoneelse@test.com", password: "otherpass")

    # Create a Post by post_owner (with one tag)
    @post = @post_owner.posts.create!(
      title: "Post for Comments",
      body: "Body text",
      tags: [Tag.find_or_create_by(name: "testtag")]
    )

    # Create an existing comment by comment_owner
    @comment = @post.comments.create!(
      body: "Existing comment",
      user: @comment_owner
    )
  end

  test "GET /posts/:post_id/comments (requires auth)" do
    get "/posts/#{@post.id}/comments", as: :json
    assert_response :unauthorized

    get "/posts/#{@post.id}/comments",
        headers: { "Authorization" => "Bearer #{@token_other}" },
        as: :json
    assert_response :success
    arr = json_response
    # Should include the existing comment
    assert arr.any? { |c| c['id'] == @comment.id }
  end

  test "POST /posts/:post_id/comments (happy path)" do
    post "/posts/#{@post.id}/comments",
         headers: { "Authorization" => "Bearer #{@token_other}" },
         params: { comment: { body: "Nice post!" } },
         as: :json

    assert_response :created
    body = json_response
    assert_equal "Nice post!", body['body']
    assert_equal @other_user.id, body['user']['id']
  end

  test "POST /posts/:post_id/comments (failure: blank body)" do
    post "/posts/#{@post.id}/comments",
         headers: { "Authorization" => "Bearer #{@token_other}" },
         params: { comment: { body: "" } },
         as: :json

    assert_response :unprocessable_entity
    assert json_response['errors'].any? { |err| err.downcase.include?("body can't be blank") }
  end

  test "PUT /posts/:post_id/comments/:id by non-owner (forbidden)" do
    put "/posts/#{@post.id}/comments/#{@comment.id}",
        headers: { "Authorization" => "Bearer #{@token_other}" },
        params: { comment: { body: "Trying to edit someone else’s comment" } },
        as: :json

    assert_response :forbidden
    assert_equal "Forbidden: not comment owner", json_response['error']
  end

  test "PUT /posts/:post_id/comments/:id by owner (success)" do
    put "/posts/#{@post.id}/comments/#{@comment.id}",
        headers: { "Authorization" => "Bearer #{@token_comment_owner}" },
        params: { comment: { body: "Edited my own comment" } },
        as: :json

    assert_response :success
    assert_equal "Edited my own comment", json_response['body']
  end

  test "DELETE /posts/:post_id/comments/:id by non-owner (forbidden)" do
    delete "/posts/#{@post.id}/comments/#{@comment.id}",
           headers: { "Authorization" => "Bearer #{@token_other}" },
           as: :json

    assert_response :forbidden
    assert_equal "Forbidden: not comment owner", json_response['error']
  end

  test "DELETE /posts/:post_id/comments/:id by owner (success)" do
    delete "/posts/#{@post.id}/comments/#{@comment.id}",
           headers: { "Authorization" => "Bearer #{@token_comment_owner}" },
           as: :json

    assert_response :no_content
    assert_nil Comment.find_by(id: @comment.id)
  end
end
