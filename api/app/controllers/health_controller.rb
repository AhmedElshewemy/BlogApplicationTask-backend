class HealthController < ApplicationController
  def check
    head :ok
    DemoJob.perform_later("Hello")
  end
end
