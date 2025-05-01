# app/controllers/health_controller.rb (or create a custom one)
class HealthController < ApplicationController
  skip_before_action :authenticate_user!
  def show
    Rails.logger.info "Health check request headers: #{request.headers.env.select { |k, _| k.start_with?('HTTP_') }}"
    render json: "OK", status: :ok
  end
end
