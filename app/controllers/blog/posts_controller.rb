class Blog::PostsController < ApplicationController
  before_action :authenticate_employee!, only: [ :create, :update ]
  before_action :restrict_to_admin, only: [ :create, :update ]
  before_action :set_post, only: [ :show, :update, :tags ]

  def index
    posts =  Blog::Post.where(status: "published").includes(:employee)
    render json: {
      posts: posts.map { |post| post_json(post) }
    }, status: :ok
  end

  def show
    render json: { post: post_json(@post) }, status: :ok
  end

  def create
    post = current_employee.posts.new(post_params)
    if post.save
      # notify_users(post)
      NotificationService.notify_new_blog(post)
      render json: { message: "Post created successfully.", post: post_json(post) }, status: :created
    else
      render json: { message: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      render json: { message: "Post updated successfully.", post: post_json(@post) }, status: :ok
    else
      render json: { message: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def tags
    render json: { tags: @post.tags.as_json(only: [ :id, :name, :slug ]) }, status: :ok
  end

  def related
    # Find posts with same category or shared tags, excluding the specified post
    related_posts =  Blog::Post.where(status: "published")
                       .where(category: params[:category_id])
                       .or(Post.joins(:tags).where(blog_tags: { id: params[:tag_ids] }))
                       .where.not(id: params[:exclude_post_id])
                       .includes(:employee, :category, :tags)
                       .distinct
                       .limit(5)
    render json: {
      posts: related_posts.map { |post| post_json(post) }
    }, status: :ok
  end

  private

  def set_post
    @post =  Blog::Post.includes(:employee, :category, :tags).find_by!(slug: params[:slug])
  rescue ActiveRecord::RecordNotFound
    render json: { message: "Post not found" }, status: :not_found
  end

  def post_params
    params.require(:post).permit(
      :title, :slug, :content, :excerpt, :featured_image, :category, :status,
      :is_featured, :published_at, tag_ids: []
    )
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
      author_name: post.employee&.full_name,
      author_avatar_url: post.employee&.avatar&.attached? ? rails_blob_url(post.employee.avatar) : nil,
      category: post.category&.as_json(only: [ :id, :name, :slug, :description ]),
      tags: post.tags.as_json(only: [ :id, :name, :slug ])
    )
  end
end
