class PostsController < ApplicationController

  before_action :set_post,   only: [:show, :update, :destroy]
  before_action :authorize_owner!, only: [:update, :destroy]

  # GET /posts
  def index
    # Returns all posts (you could paginate or filter in real apps)
    @posts = Post.includes(:tags, :user).all

    render json: @posts.as_json(
      only: [:id, :title, :body, :created_at, :updated_at],
      include: {
        user: { only: [:id, :name, :email] },
        tags: { only: [:id, :name] }
      }
    ), status: :ok
  end

  # GET /posts/:id
  def show
    render json: @post.as_json(
      only: [:id, :title, :body, :created_at, :updated_at],
      include: {
        user: { only: [:id, :name, :email] },
        tags: { only: [:id, :name] },
        comments: {
          only: [:id, :body, :created_at, :updated_at],
          include: {
            user: { only: [:id, :name, :email] }
          }
        }
      }
    ), status: :ok
  end

  # POST /posts
  def create
    # Assign current_user as the author
    @post = @current_user.posts.build(post_params.except(:tags))

    # Handle tags: find_or_create each by name, then assign
    tag_names = post_params[:tags] || []
    @post.tags = tag_names.map { |tname| Tag.find_or_create_by(name: tname.downcase.strip) }

    if @post.save
      # Schedule the DeletePostJob to run exactly 24 hours later
      DeletePostJob.set(wait: 24.hours).perform_later(@post.id)  
      render json: @post.as_json(
        only: [:id, :title, :body, :created_at, :updated_at],
        include: {
          user: { only: [:id, :name, :email] },
          tags: { only: [:id, :name] }
        }
      ), status: :created
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /posts/:id
  def update
    # `authorize_owner!` ensures only the author can reach here

    # Update title/body if provided
    if @post.update(post_params.except(:tags))
      # If tags array passed, update them:
      if post_params[:tags]
        new_tag_names = post_params[:tags].map { |t| t.downcase.strip }
        # Replace current associations with new Tag records
        @post.tags = new_tag_names.map { |tname| Tag.find_or_create_by(name: tname) }
      end

      render json: @post.as_json(
        only: [:id, :title, :body, :created_at, :updated_at],
        include: {
          user: { only: [:id, :name, :email] },
          tags: { only: [:id, :name] }
        }
      ), status: :ok
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /posts/:id
  def destroy
    # `authorize_owner!` ensures only author hits this
    @post.destroy
    head :no_content
  end

  private

  def set_post
    @post = Post.includes(:tags, :user, comments: :user).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Post not found" }, status: :not_found
  end

  # Only the author (post.user) can update or delete
  def authorize_owner!
    render json: { error: "Forbidden: not post owner" }, status: :forbidden unless @post.user_id == @current_user.id
  end

  # Strong params: require title, body, tags (array of strings).  
  # If tags not sent, `:tags` will be nil.
  def post_params
    params.require(:post).permit(:title, :body, tags: [])
  end
end
