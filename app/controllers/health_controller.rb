# app/controllers/health_controller.rb (or create a custom one)
class HealthController < ApplicationController
  # respond_to :json
  # skip_before_action :authenticate_user!
  # def up
  #   # Optional: Check database connections
  #   %i[primary cache queue cable].each do |db|
  #     ActiveRecord::Base.connected_to(database: db) do
  #       raise "Database #{db} not connected" unless ActiveRecord::Base.connection.active?
  #     end
  #   end
  #   render plain: "OK", status: :ok
  # rescue StandardError => e
  #   render plain: "Error: #{e.message}", status: :service_unavailable
  # end
end
