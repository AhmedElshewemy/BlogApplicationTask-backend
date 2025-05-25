class HealthController < ApplicationController
  def check
    DemoJob.perform_later("Hello")
    head :ok
  end
end
