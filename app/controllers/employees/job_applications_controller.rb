# app/controllers/admin/job_applications_controller.rb
module Employees
  class JobApplicationsController < ApplicationController
    before_action :authenticate_employee!
    before_action :ensure_admin
    before_action :set_job_application, only: %i[show update]

    # GET /admin/job_applications
    def index
      @job_applications = Career::JobApplication.all
      render json: @job_applications, include: { job_listing: { only: [ :title ] }, applicant: { only: [ :full_name, :company_name ] } }
    end

    # GET /admin/job_applications/:id
    def show
      render json: @job_application, include: { job_listing: { only: [ :title ] }, applicant: { only: [ :full_name, :company_name ] } }
    end

    # PATCH/PUT /admin/job_applications/:id
    def update
      if @job_application.update(job_application_params)
        render json: @job_application, status: :ok
      else
        render json: { errors: @job_application.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def set_job_application
      @job_application = Career::JobApplication.find(params[:id])
    end

    def job_application_params
      params.require(:job_application).permit(:status, :reviewer_id)
    end

    def ensure_admin
      unless current_employee&.role == "admin"
        render json: { error: "Unauthorized: Admin access required" }, status: :unauthorized
      end
    end
  end
end
