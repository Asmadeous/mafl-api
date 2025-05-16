# class Blog::PostsController < ApplicationController
#   before_action :authenticate_employee!, only: [ :create, :update ]
#   before_action :restrict_to_admin, only: [ :create, :update ]
#   before_action :set_post, only: [ :show, :update, :tags ]
#   skip_before_action :authenticate_user!, only: [ :index, :show, :related ]

#   def index
#     posts = Blog::Post.where(status: "published")
#                       .includes(:employee)
#                       .page(params[:page])
#                       .per(params[:per_page] || 10)
#     render json: {
#       posts: posts.map { |post| post_json(post) },
#       pagination: {
#         current_page: posts.current_page,
#         total_pages: posts.total_pages,
#         total_count: posts.total_count,
#         per_page: posts.limit_value
#       }
#     }, status: :ok
#   end

#   def show
#     render json: { post: post_json(@post) }, status: :ok
#   end

#   def create
#     post = current_employee.posts.new(post_params)
#     if post.save
#       NotificationService.notify_new_blog(post)
#       render json: { message: "Post created successfully.", post: post_json(post) }, status: :created
#     else
#       render json: { message: post.errors.full_messages }, status: :unprocessable_entity
#     end
#   end

#   def update
#     if @post.update(post_params)
#       render json: { message: "Post updated successfully.", post: post_json(@post) }, status: :ok
#     else
#       render json: { message: @post.errors.full_messages }, status: :unprocessable_entity
#     end
#   end

#   def tags
#     render json: { tags: @post.tags.as_json(only: [ :id, :name, :slug ]) }, status: :ok
#   end

#   def related
#     related_posts = Blog::Post.where(status: "published")
#                              .where(category: params[:category_id])
#                              .or(Blog::Post.joins(:tags).where(blog_tags: { id: params[:tag_ids] }))
#                              .where.not(id: params[:exclude_post_id])
#                              .includes(:employee, :category, :tags)
#                              .distinct
#                              .page(params[:page])
#                              .per(params[:per_page] || 5)
#     render json: {
#       posts: related_posts.map { |post| post_json(post) },
#       pagination: {
#         current_page: related_posts.current_page,
#         total_pages: related_posts.total_pages,
#         total_count: related_posts.total_count,
#         per_page: related_posts.limit_value
#       }
#     }, status: :ok
#   end

#   private

#   def set_post
#     @post = Blog::Post.includes(:employee, :category, :tags).find_by!(slug: params[:slug])
#   rescue ActiveRecord::RecordNotFound
#     render json: { message: "Post not found" }, status: :not_found
#   end

#   def post_params
#     params.require(:post).permit(
#       :title, :slug, :content, :excerpt, :featured_image, :category, :status,
#       :is_featured, :published_at, tag_ids: []
#     )
#   end

#   def restrict_to_admin
#     unless current_employee&.admin?
#       render json: { message: "Only admins can manage blog posts." }, status: :forbidden
#     end
#   end

#   def notify_users(post)
#     User.find_each do |user|
#       user.notifications.create(message: "New Blog post #{post.id}: #{post.title} by #{post.employee.full_name}.")
#     end
#   end

#   def post_json(post)
#     post.as_json.merge(
#       author_name: post.employee&.full_name,
#       author_avatar_url: post.employee&.avatar&.attached? ? rails_blob_url(post.employee.avatar) : nil,
#       category: post.category&.as_json(only: [ :id, :name, :slug, :description ]),
#       tags: post.tags.as_json(only: [ :id, :name, :slug ])
#     )
#   end
# end


class Blog::PostsController < ApplicationController
  before_action :authenticate_employee!, only: [ :create, :update ]
  before_action :restrict_to_admin, only: [ :create, :update ]
  before_action :set_post, only: [ :show, :update, :tags ]
  skip_before_action :authenticate_user!, only: [ :index, :show, :related ]

  def index
    posts = Blog::Post.where(status: "published").includes(:employee, :category, :tags)
    begin
      posts = posts.page(params[:page]).per(params[:per_page] || 10)
    rescue NameError => e
      Rails.logger.error("Pagination error: #{e.message}. Ensure will_paginate gem is installed.")
      posts = posts.limit(params[:per_page] || 10).offset((params[:page].to_i - 1) * (params[:per_page] || 10).to_i)
    end
    render json: {
      posts: ActiveModelSerializers::SerializableResource.new(posts, each_serializer: Blog::PostSerializer),
      pagination: {
        current_page: posts.respond_to?(:current_page) ? posts.current_page : (params[:page].to_i || 1),
        total_pages: posts.respond_to?(:total_pages) ? posts.total_pages : (Blog::Post.where(status: "published").count.to_f / (params[:per_page] || 10).to_i).ceil,
        total_count: posts.respond_to?(:total_count) ? posts.total_count : Blog::Post.where(status: "published").count,
        per_page: (params[:per_page] || 10).to_i
      }
    }, status: :ok
  end

  def show
    render json: { post: Blog::PostSerializer.new(@post) }, status: :ok
  end

  def create
    post = current_employee.posts.new(post_params)
    if post.save
      NotificationService.notify_new_blog(post)
      render json: { message: "Post created successfully.", post: Blog::PostSerializer.new(post) }, status: :created
    else
      render json: { message: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      render json: { message: "Post updated successfully.", post: Blog::PostSerializer.new(@post) }, status: :ok
    else
      render json: { message: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def tags
    render json: { tags: ActiveModelSerializers::SerializableResource.new(@post.tags, each_serializer: Blog::TagSerializer) }, status: :ok
  end

  def related
    related_posts = Blog::Post.where(status: "published")
                             .where(category: params[:category_id])
                             .or(Blog::Post.joins(:tags).where(blog_tags: { id: params[:tag_ids] }))
                             .where.not(id: params[:exclude_post_id])
                             .includes(:employee, :category, :tags)
                             .distinct
    begin
      related_posts = related_posts.page(params[:page]).per(params[:per_page] || 5)
    rescue NameError => e
      Rails.logger.error("Pagination error: #{e.message}. Ensure will_paginate gem is installed.")
      related_posts = related_posts.limit(params[:per_page] || 5).offset((params[:page].to_i - 1) * (params[:per_page] || 5).to_i)
    end
    render json: {
      posts: ActiveModelSerializers::SerializableResource.new(related_posts, each_serializer: Blog::PostSerializer),
      pagination: {
        current_page: related_posts.respond_to?(:current_page) ? related_posts.current_page : (params[:page].to_i || 1),
        total_pages: related_posts.respond_to?(:total_pages) ? related_posts.total_pages : (Blog::Post.where(status: "published").count.to_f / (params[:per_page] || 5).to_i).ceil,
        total_count: related_posts.respond_to?(:total_count) ? related_posts.total_count : Blog::Post.where(status: "published").count,
        per_page: (params[:per_page] || 5).to_i
      }
    }, status: :ok
  end

  private

  def set_post
    @post = Blog::Post.includes(:employee, :category, :tags).find_by!(slug: params[:slug])
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
end
