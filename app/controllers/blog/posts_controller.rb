class Blog::PostsController < ApplicationController
  before_action :authenticate_employee!, only: [ :create, :update ]
  before_action :restrict_to_admin, only: [ :create, :update ]

  def index
    posts = Blog::Post.where(status: "published").includes(:employee, :category, :tags)
    render json: {
      posts: posts.map { |post| post_json(post) }
    }, status: :ok
  end

  def show
    post = Blog::Post.includes(:employee, :category, :tags).find_by(slug: params[:slug])
    render json: { post: post_json(post) }, status: :ok
  end

  def create
    post = current_employee.posts.new(post_params)
    if post.save
      notify_users(post)
      render json: { message: "Post created successfully.", post: post_json(post) }, status: :created
    else
      render json: { message: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    post = Blog::Post.find_by(slug: params[:slug])
    if post.update(post_params)
      render json: { message: "Post updated successfully.", post: post_json(post) }, status: :ok
    else
      render json: { message: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :slug, :content, :excerpt, :featured_image, :category_id, :status, :is_featured, :published_at, tag_ids: [])
  end

  def restrict_to_admin
    unless current_employee&.admin?
      render json: { message: "Only admins can manage blog posts." }, status: :forbidden
    end
  end

  def notify_users(post)
    User.find_each do |user|
      user.notifications.create(message: "New Blog post #{post.id}: #{post.title} by #{post.employee.full_name}.")
    end
  end

  def post_json(post)
    post.as_json.merge(
      author_name: post.employee.full_name,
      author_avatar_url: post.employee.avatar.attached? ? rails_blob_url(post.employee.avatar) : nil,
      category: post.category.as_json,
      tags: post.tags.as_json
    )
  end
end
