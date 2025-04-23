# app/models/blog/post.rb
class Blog::Post < ApplicationRecord
  validates :title, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :content, presence: true
  validates :status, inclusion: { in: %w[draft published] }

  belongs_to :category, class_name: "Blog::Category", foreign_key: "category_id", optional: true
  belongs_to :employee, foreign_key: "employee_id", optional: true
  has_many :posts_tags, class_name: "Blog::PostsTag", foreign_key: "post_id"
  has_many :tags, through: :posts_tags, class_name: "Blog::Tag", foreign_key: "tag_id"
  has_one_attached :featured_image


  after_create_commit :notify_users, if: :published?

  private

  def published?
    status == "published"
  end

  def notify_users
    User.find_each do |user|
      notification = user.notifications.create!(
        message: "New Blog post #{id}: #{title} by #{employee&.full_name || 'Unknown Author'}."
      )
      ActionCable.server.broadcast(
        "notifications:#{user.id}",
        {
          id: notification.id,
          message: notification.message,
          read: notification.read,
          created_at: notification.created_at.iso8601,
          post_slug: slug,
          author_name: employee&.full_name || "Unknown Author",
          author_avatar_url: employee&.avatar&.attached? ? Rails.application.routes.url_helpers.rails_blob_url(employee.avatar) : nil
        }
      )
    end
  end
end
