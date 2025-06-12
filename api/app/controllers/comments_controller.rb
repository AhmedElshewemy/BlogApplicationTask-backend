class CommentsController < ApplicationController
  before_action :set_post
  before_action :set_comment, only: [:update, :destroy]
  before_action :authorize_comment_owner!, only: [:update, :destroy]

  # GET /posts/:post_id/comments
  def index
    @comments = @post.comments.includes(:user)
    render json: @comments.as_json(
      only: [:id, :body, :created_at, :updated_at],
      include: { user: { only: [:id, :name, :email] } }
    ), status: :ok
  end

  # POST /posts/:post_id/comments
  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = @current_user

    if @comment.save
      render json: @comment.as_json(
        only: [:id, :body, :created_at, :updated_at],
        include: { user: { only: [:id, :name, :email] } }
      ), status: :created
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /posts/:post_id/comments/:id
  def update
    if @comment.update(comment_params)
      render json: @comment.as_json(
        only: [:id, :body, :created_at, :updated_at],
        include: { user: { only: [:id, :name, :email] } }
      ), status: :ok
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /posts/:post_id/comments/:id
  def destroy
    @comment.destroy
    head :no_content
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Post not found" }, status: :not_found
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Comment not found for this post" }, status: :not_found
  end

  # Only the comment author can edit or delete
  def authorize_comment_owner!
    render json: { error: "Forbidden: not comment owner" }, status: :forbidden unless @comment.user_id == @current_user.id
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
