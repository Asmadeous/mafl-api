class AppointmentsController < ApplicationController
  before_action :authenticate_user_or_client!, except: [ :verify, :reschedule ]
  before_action :authenticate_admin!, only: [ :verify, :reschedule ]
  before_action :set_appointment, only: [ :show, :verify, :reschedule ]

  # GET /appointments
  def index
    @appointments = current_participant.appointments
    render json: @appointments, each_serializer: AppointmentSerializer
  end

  # GET /appointments/:id
  def show
    render json: @appointment, serializer: AppointmentSerializer
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Appointment not found" }, status: :not_found
  end

  # POST /appointments
  def create
    @appointment = current_participant.appointments.build(appointment_params)
    @appointment.status = "pending" # All new appointments start as pending

    if @appointment.save
      # Notify admin for verification
      notify_admin(@appointment)
      render json: @appointment, serializer: AppointmentSerializer, status: :created
    else
      render json: { errors: @appointment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /appointments/:id/verify
  def verify
    if @appointment.pending?
      @appointment.update(status: "approved")
      notify_participant(@appointment, "Your appointment has been approved.")
      render json: { message: "Appointment approved" }, status: :ok
    else
      render json: { error: "Appointment is not in pending status" }, status: :unprocessable_entity
    end
  end

  # PATCH /appointments/:id/reschedule
  def reschedule
    if @appointment.pending? || @appointment.approved?
      if @appointment.update(reschedule_params.merge(status: "rescheduled"))
        notify_participant(@appointment, "Your appointment has been rescheduled to #{@appointment.scheduled_at}.")
        render json: @appointment, serializer: AppointmentSerializer, status: :ok
      else
        render json: { errors: @appointment.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: "Appointment cannot be rescheduled" }, status: :unprocessable_entity
    end
  end

  private

  def set_appointment
    @appointment = Appointment.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Appointment not found" }, status: :not_found
  end

  def appointment_params
    params.require(:appointment).permit(:employee_id, :scheduled_at, :purpose)
  end

  def reschedule_params
    params.require(:appointment).permit(:scheduled_at)
  end

  def authenticate_user_or_client!
    unless current_user || current_client || current_guest
      render json: { error: "Unauthorized: User, Client, or Guest login required" }, status: :unauthorized
    end
  end

  def authenticate_admin!
    unless current_employee&.role == "admin"
      render json: { error: "Unauthorized: Admin access required" }, status: :unauthorized
    end
  end

  def current_participant
    current_user || current_client || current_guest
  end

  def notify_admin(appointment)
    admin = Employee.find_by(role: "admin")
    return unless admin

    Notification.create(
      notifiable: appointment,
      message: "New appointment request from #{current_participant&.name || 'Guest'} needs verification.",
      link: "/appointments/#{appointment.id}",
      notifiable_id: admin.id,
      notifiable_type: "Employee"
    )
  end

  def notify_participant(appointment, message)
    participant = appointment.user || appointment.client || appointment.guest
    return unless participant

    Notification.create(
      notifiable: appointment,
      message: message,
      link: "/appointments/#{appointment.id}",
      notifiable_id: participant.id,
      notifiable_type: participant.class.name
    )
  end
end
