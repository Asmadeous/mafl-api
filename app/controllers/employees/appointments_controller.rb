# app/controllers/admin/appointments_controller.rb
module Employees
  class AppointmentsController < ApplicationController
    before_action :authenticate_employee!
    before_action :ensure_admin
    before_action :set_appointment, only: %i[show update destroy]

    # GET /admin/appointments
    def index
      @appointments = Appointment.all
      render json: @appointments, each_serializer: AppointmentSerializer
    end

    # GET /admin/appointments/:id
    def show
      render json: @appointment, serializer: AppointmentSerializer
    end

    # POST /admin/appointments
    def create
      @appointment = Appointment.new(appointment_params)
      @appointment.employee = current_employee

      if @appointment.save
        render json: @appointment, status: :created, serializer: AppointmentSerializer
      else
        render json: { errors: @appointment.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /admin/appointments/:id
    def update
      if @appointment.update(appointment_params)
        render json: @appointment, serializer: AppointmentSerializer
      else
        render json: { errors: @appointment.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /admin/appointments/:id
    def destroy
      @appointment.destroy
      head :no_content
    end

    private

    def set_appointment
      @appointment = Appointment.find(params[:id])
    end

    def appointment_params
      params.require(:appointment).permit(:scheduled_at, :purpose, :client_id, :user_id)
    end

    def ensure_admin
      unless current_employee&.role == "admin"
        render json: { error: "Unauthorized: Admin access required" }, status: :unauthorized
      end
    end
  end
end
