# app/controllers/admin/job_listings_controller.rb
module Employees
  class JobListingsController < ApplicationController
    before_action :authenticate_employee!
    before_action :ensure_admin
    before_action :set_job_listing, only: %i[show update destroy]

    # GET /admin/job_listings
    def index
      @job_listings = Career::JobListing.all
      render json: @job_listings, each_serializer: JobListingSerializer
    end

    # GET /admin/job_listings/:id
    def show
      render json: @job_listing, serializer: JobListingSerializer
    end

    # POST /admin/job_listings
    def create
      @job_listing = Career::JobListing.new(job_listing_params)
      @job_listing.employee = current_employee

      if @job_listing.save
        render json: @job_listing, status: :created, serializer: JobListingSerializer
      else
        render json: { errors: @job_listing.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /admin/job_listings/:id
    def update
      if @job_listing.update(job_listing_params)
        render json: @job_listing, serializer: JobListingSerializer
      else
        render json: { errors: @job_listing.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /admin/job_listings/:id
    def destroy
      @job_listing.destroy
      head :no_content
    end

    private

    def set_job_listing
      @job_listing = Career::JobListing.find(params[:id])
    end

    def job_listing_params
      params.require(:job_listing).permit(:title, :description, :status)
    end

    def ensure_admin
      unless current_employee&.role == "admin"
        render json: { error: "Unauthorized: Admin access required" }, status: :unauthorized
      end
    end
  end
end
