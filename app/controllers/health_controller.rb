# app/controllers/health_controller.rb (or create a custom one)
class HealthController < ApplicationController
  def show
    Rails.logger.info "Health check request headers: #{request.headers.env.select { |k, _| k.start_with?('HTTP_') }}"
    render plain: "OK", status: :ok
  end
end
