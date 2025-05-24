class DemoJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "👋 Hello from Sidekiq job with args: #{args.inspect}"
  end
end
