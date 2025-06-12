class DeletePostJob < ApplicationJob
  queue_as :default

  def perform(post_id)
    post = Post.find_by(id: post_id)
    return unless post

    # Only delete if the post is at least 24 hours old
    if post.created_at <= 24.hours.ago
      post.destroy
    end
  end
end
