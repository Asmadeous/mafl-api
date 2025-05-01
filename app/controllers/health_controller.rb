# app/controllers/health_controller.rb (or create a custom one)
class HealthController < ApplicationController
  respond_to :json
  skip_before_action :authenticate_user!
  def show
    Rails.logger.info "Health check request headers: #{request.headers.env.select { |k, _| k.start_with?('HTTP_') }}"
    render plain: "OK", status: :ok
  end
end
