class DeletePostJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    post = Post.find_by(id: post_id)
    return unless post

    # Only delete if it’s at least 24h old (guard against clock skew or manual rescheduling)
    if post.created_at <= 24.hours.ago
      post.destroy
    end
  end
end
