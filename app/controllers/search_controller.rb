class SearchController < ApplicationController
  def index
    query = params[:q]&.strip
    unless query.present?
      render json: { error: "Query parameter is required" }, status: :bad_request
      return
    end

    results = {
      blog_posts: BlogPost.where("title ILIKE ? OR content ILIKE ?", "%#{query}%", "%#{query}%").map do |post|
        { id: post.id, title: post.title, type: "BlogPost" }
      end,
      job_listings: JobListing.where("title ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%").map do |job|
        { id: job.id, title: job.title, type: "JobListing" }
      end
    }
    render json: results, status: :ok
  rescue StandardError => e
    render json: { error: "Failed to perform search: #{e.message}" }, status: :internal_server_error
  end
end