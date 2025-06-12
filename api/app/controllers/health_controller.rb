# Handles health check endpoint
class HealthController < ApplicationController
  # Skips the authorization check for the health check action
  skip_before_action :authorize_request, only: :check

  def check
    DemoJob.perform_later("Hello")
    head :ok
  end
end
