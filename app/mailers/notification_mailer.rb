class NotificationMailer < ApplicationMailer
  default from: "ndegwaian001@gmail.com"

  def new_post_notification(notification)
    @notification = notification
    @user = notification.user
    @post = Blog::Post.find_by(id: notification.message.scan(/Blog post (\d+)/).flatten.first)
    mail(to: @user.email, subject: "New Blog Post by #{@post.employee.full_name}")
  end
end
