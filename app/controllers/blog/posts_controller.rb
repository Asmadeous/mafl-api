class Blog::PostsController < ApplicationController
  before_action :authenticate_employee!, only: [ :create, :update ]
  before_action :restrict_to_admin, only: [ :create, :update ]
  before_action :set_post, only: [ :show, :update, :tags ]
  skip_before_action :authenticate_user!, only: [ :index, :show, :related ]

  def index
    page = [ params[:page].to_i, 1 ].max
    per_page = params[:per_page].to_i
    per_page = 10 if per_page <= 0
    per_page = [ per_page, 100 ].min

    posts = Blog::Post.where(status: "published")
                      .includes(:employee, :category, :tags)
                      .paginate(page: page, per_page: per_page)

    options = { include: [ :employee, :category, :tags ] }
    serialized_posts = Blog::PostSerializer.new(posts, options).serializable_hash

    render json: {
      data: serialized_posts[:data],
      meta: {
        pagination: {
          current_page: posts.current_page,
          total_pages: posts.total_pages,
          total_count: posts.total_entries,
          per_page: per_page
        }
      }
    }, status: :ok
  end

  def show
    options = { include: [ :employee, :category, :tags ] }
    render json: Blog::PostSerializer.new(@post, options).serializable_hash, status: :ok
  end

  def create
    post = current_employee.posts.new(post_params)
    if post.save
      NotificationService.notify_new_blog(post)
      render json: Blog::PostSerializer.new(post).serializable_hash, status: :created
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity

    end
  end

  def update
    if @post.update(post_params)
      render json: Blog::PostSerializer.new(@post).serializable_hash, status: :ok
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def tags
    render json: Blog::TagSerializer.new(@post.tags).serializable_hash, status: :ok
  end

  def related
    page = [ params[:page].to_i, 1 ].max
    per_page = (params[:per_page] || 5).to_i

    related_posts = Blog::Post.where(status: "published")
                              .where(category: params[:category_id])
                              .or(Blog::Post.joins(:tags).where(blog_tags: { id: params[:tag_ids] }))
                              .where.not(id: params[:exclude_post_id])
                              .includes(:employee, :category, :tags)
                              .distinct
                              .paginate(page: page, per_page: per_page)

    options = { include: [ :employee, :category, :tags ] }
    serialized_posts = Blog::PostSerializer.new(related_posts, options).serializable_hash

    render json: {
      data: serialized_posts[:data],
      included: serialized_posts[:included],
      meta: {
        pagination: {
          current_page: related_posts.current_page,
          total_pages: related_posts.total_pages,
          total_count: related_posts.total_entries,
          per_page: per_page
        }
      }
    }, status: :ok
  end

  private

  def set_post
    @post = if params[:slug]
              Blog::Post.includes(:employee, :category, :tags).find_by!(slug: params[:slug])
    elsif params[:id]
              Blog::Post.includes(:employee, :category, :tags).find_by!(id: params[:id])
    else
              raise ActiveRecord::RecordNotFound
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Blog post not found" }, status: :not_found
  end

  def post_params
    params.require(:post).permit(
      :title, :slug, :content, :excerpt, :featured_image, :category_id, :status,
      :is_featured, :published_at, tag_ids: []
    )
  end

  def restrict_to_admin
    unless current_employee&.admin?
      render json: { message: "Only admins can manage blog posts." }, status: :forbidden
    end
  end
end
