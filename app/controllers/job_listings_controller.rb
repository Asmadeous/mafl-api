# app/controllers/job_listings_controller.rb
class JobListingsController < ApplicationController
  skip_before_action :authenticate_user!
  # GET /job_listings
  def index
    @job_listings = Career::JobListing.active
    render json: @job_listings, each_serializer: JobListingSerializer
  end

  # GET /job_listings/:id
  def show
    @job_listing = Career::JobListing.active.find(params[:id])
    render json: @job_listing, serializer: JobListingSerializer
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Job listing not found or not active" }, status: :not_found
  end
end
