class HealthController < ApplicationController
  skip_before_action :authorize_request, only: :check

  def check
    DemoJob.perform_later("Hello")
    head :ok
  end
end
