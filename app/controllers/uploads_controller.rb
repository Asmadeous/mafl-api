class UploadsController < ApplicationController
  before_action :authenticate_user_or_guest!

  def create
    blob = ActiveStorage::Blob.create_and_upload!(
      io: params[:file],
      filename: params[:file].original_filename,
      content_type: params[:file].content_type
    )
    render json: { id: blob.id, url: url_for(blob) }, status: :created
  rescue StandardError => e
    render json: { error: "Failed to upload file: #{e.message}" }, status: :unprocessable_entity
  end

  private

  def authenticate_user_or_guest!
    unless current_user || current_guest
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end