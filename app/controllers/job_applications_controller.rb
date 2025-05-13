class JobApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job_listing

  def create
    job_application = JobApplication.new(
      job_listing_id: @job_listing.id,
      applicant_type: applicant_type,
      applicant_id: current_applicant.id,
      content: params[:content],
      status: "pending"
    )
    if job_application.save
      render json: job_application, status: :created
    else
      render json: { error: job_application.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: "Failed to create job application: #{e.message}" }, status: :internal_server_error
  end

  private

  def authenticate_applicant!
    unless current_user || current_guest
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def applicant_type
    current_user ? "User" : "Guest"
  end

  def current_applicant
    current_user || current_guest
  end

  def set_job_listing
    @job_listing = JobListing.find(params[:job_listing_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Job listing not found" }, status: :not_found
  end
end
