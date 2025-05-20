class Blog::PostsController < ApplicationController
  before_action :authenticate_employee!, only: [ :create, :update ]
  before_action :restrict_to_admin, only: [ :create, :update ]
  before_action :set_post, only: [ :show, :update, :tags ]
  skip_before_action :authenticate_user!, only: [ :index, :show, :related ]

  def index
    posts = Blog::Post
              .where(status: "published")
              .includes(:employee, :category, :tags)
              .paginate(page: current_page, per_page: per_page)

    render_serialized_posts(posts)
  end

  def show
    render_serialized_post(@post)
  end

  def create
    post = current_employee.posts.new(post_params)

    if post.save
      NotificationService.notify_new_blog(post)
      render_serialized_post(post, status: :created)
    else
      render_error(post)
    end
  end

  def update
    if @post.update(post_params)
      render_serialized_post(@post)
    else
      render_error(@post)
    end
  end

  def tags
    render json: Blog::TagSerializer.new(@post.tags).serializable_hash, status: :ok
  end

  def related
    related_posts = Blog::Post
                      .where(status: "published")
                      .where(category_id: params[:category_id])
                      .or(
                        Blog::Post.joins(:tags).where(blog_tags: { id: params[:tag_ids] })
                      )
                      .where.not(id: params[:exclude_post_id])
                      .includes(:employee, :category, :tags)
                      .distinct
                      .paginate(page: current_page, per_page: per_page)

    render_serialized_posts(related_posts)
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
      :title,
      :slug,
      :content,
      :excerpt,
      :featured_image,
      :category_id,
      :status,
      :is_featured,
      :published_at,
      tag_ids: []
    )
  end

  def restrict_to_admin
    unless current_employee&.admin?
      render json: { message: "Only admins can manage blog posts." }, status: :forbidden
    end
  end

  def current_page
    [ params[:page].to_i, 1 ].max
  end

  def per_page
    limit = params[:per_page].to_i
    limit = 10 if limit <= 0
    [ limit, 100 ].min
  end

  def render_serialized_posts(posts)
    options = { include: [ :employee, :category, :tags ] }
    serialized = Blog::PostSerializer.new(posts, options).serializable_hash

    render json: {
      data: serialized[:data],
      included: serialized[:included],
      meta: {
        pagination: {
          current_page: posts.current_page,
          total_pages: posts.total_pages,
          total_count: posts.total_entries,
          per_page: posts.per_page
        }
      }
    }, status: :ok
  end

  def render_serialized_post(post, status: :ok)
    options = { include: [ :employee, :category, :tags ] }
    serialized = Blog::PostSerializer.new(post, options).serializable_hash

    render json: {
      data: serialized[:data],
      included: serialized[:included]
    }, status: status
  end

  def render_error(resource)
    render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
  end
end
