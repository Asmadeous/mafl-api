# db/seeds.rb
require 'securerandom'
require 'digest/md5'

puts "🧹 Cleaning up database..."

[ Notification, Message, Conversation, Blog::PostsTag, Blog::Post, Blog::Tag, Blog::Category, User, Employee ].each(&:destroy_all)

puts "🗑 Purging Active Storage attachments..."
ActiveStorage::Attachment.destroy_all
ActiveStorage::Blob.destroy_all
ActiveStorage::VariantRecord.destroy_all

puts "✅ Database cleaned."

USER_ID = "a1b2c3d4-e5f6-7890-abcd-1234567890ab"
EMPLOYEE_ID = "b2c3d4e5-f6a7-8901-bcde-2345678901bc"

def create_blob(filename, content)
  blob = ActiveStorage::Blob.create_and_upload!(
    io: StringIO.new(content),
    filename: filename,
    content_type: "image/jpeg",
    identify: false
  )
  puts "Created blob ID: #{blob.id}, Persisted: #{blob.persisted?}"
  blob
end

user_avatar_blob     = create_blob("user_avatar.jpg", "User avatar content")
employee_avatar_blob = create_blob("employee_avatar.jpg", "Employee avatar content")
tech_blob            = create_blob("tech_image.jpg", "Tech image content")
lifestyle_blob       = create_blob("lifestyle_image.jpg", "Lifestyle image content")

puts "👤 Creating user and employee..."

user = User.new(
  id: USER_ID,
  full_name: "Test User",
  email: "user@example.com",
  phone_number: nil,
  password: "password123",
  password_confirmation: "password123",
  jti: USER_ID,
  remember_me: false
)
user.avatar.attach(user_avatar_blob)
puts "User valid? #{user.valid?}"
puts "User errors: #{user.errors.full_messages}" unless user.valid?
user.save!
puts "User ID: #{user.id}"

employee = Employee.new(
  id: EMPLOYEE_ID,
  full_name: "Test Employee",
  email: "employee@example.com",
  phone_number: nil,
  role: "admin",
  password: "password123",
  password_confirmation: "password123",
  jti: EMPLOYEE_ID,
  remember_me: false
)
employee.avatar.attach(employee_avatar_blob)
puts "Employee valid? #{employee.valid?}"
puts "Employee errors: #{employee.errors.full_messages}" unless employee.valid?
employee.save!
puts "Employee ID: #{employee.id}"

puts "📚 Creating blog categories and tags..."

categories = Blog::Category.create!([
  { name: "Technology", slug: "technology", description: "Tech news and trends" },
  { name: "Lifestyle", slug: "lifestyle", description: "Tips for a better life" },
  { name: "Business", slug: "business", description: "Business insights and strategies" }
])
categories.each do |cat|
  puts "Category ID: #{cat.id}, Exists? #{Blog::Category.exists?(cat.id)}"
end

tags = Blog::Tag.create!([
  { name: "AI", slug: "ai" },
  { name: "Productivity", slug: "productivity" },
  { name: "Entrepreneurship", slug: "entrepreneurship" }
])

puts "📝 Creating blog posts..."

category = categories[0]
puts "Assigning category_id: #{category.id}"
post1 = Blog::Post.new(
  title: "The Future of AI",
  slug: "the-future-of-ai",
  content: "Artificial intelligence is transforming industries...",
  excerpt: "AI is reshaping the world. Learn how.",
  employee_id: EMPLOYEE_ID,
  category_id: category.id,
  status: "published",
  is_featured: true,
  published_at: 1.day.ago
)
puts "post1 category_id after assignment: #{post1.category_id}"
puts "Category exists? #{Blog::Category.exists?(category.id)}"
puts "post1 valid before attach? #{post1.valid?}"
puts "post1 errors before attach: #{post1.errors.full_messages}" unless post1.valid?
post1.featured_image.attach(tech_blob)
puts "post1 featured_image attached: #{post1.featured_image.attached?}"
puts "post1 valid after attach? #{post1.valid?}"
puts "post1 errors after attach: #{post1.errors.full_messages}" unless post1.valid?
begin
  post1.save!
  puts "post1 saved successfully, ID: #{post1.id}"
rescue ActiveRecord::NotNullViolation => e
  puts "Database constraint error: #{e.message}"
  puts "post1 attributes: #{post1.attributes.inspect}"
rescue ActiveRecord::RecordInvalid => e
  puts "Validation error: #{e.message}"
  puts "post1 errors: #{post1.errors.full_messages}"
rescue StandardError => e
  puts "Unexpected error: #{e.message}"
end
puts "post1 persisted? #{post1.persisted?}"
puts "post1 ID: #{post1.id || 'nil'}"

post2 = Blog::Post.new(
  title: "Boost Your Productivity",
  slug: "boost-your-productivity",
  content: "Top tips to get more done in less time...",
  excerpt: "Maximize your efficiency with these tips.",
  employee_id: EMPLOYEE_ID,
  category_id: categories[1].id,
  status: "published",
  is_featured: false,
  published_at: 2.days.ago
)
puts "post2 category_id: #{post2.category_id}"
puts "post2 valid? #{post2.valid?}"
puts "post2 errors: #{post2.errors.full_messages}" unless post2.valid?
post2.featured_image.attach(lifestyle_blob)
puts "post2 featured_image attached: #{post2.featured_image.attached?}"
post2.save!
puts "post2 ID: #{post2.id}"

puts "🏷 Tagging blog posts..."

Blog::PostsTag.create!([
  { post_id: post1.id, tag_id: tags[0].id },
  { post_id: post1.id, tag_id: tags[2].id },
  { post_id: post2.id, tag_id: tags[1].id }
])

puts "💬 Creating conversation and messages..."

conversation = Conversation.create!(
  user_id: USER_ID,
  employee_id: EMPLOYEE_ID,
  # conversation_id: SecureRandom.hex(16),
  last_message_at: Time.current
)

Message.create!([
  {
    conversation_id: conversation.id,
    sender_id: USER_ID,
    sender_type: "User",
    receiver_id: EMPLOYEE_ID,
    receiver_type: "Employee",
    content: "Hello, I have a question about your services.",
    read: false,
    created_at: 1.hour.ago,
    updated_at: 1.hour.ago
  },
  {
    conversation_id: conversation.id,
    sender_id: EMPLOYEE_ID,
    sender_type: "Employee",
    receiver_id: USER_ID,
    receiver_type: "User",
    content: "Sure, how can I assist you?",
    read: false,
    created_at: Time.current,
    updated_at: Time.current
  }
])

puts "🔔 Creating notifications..."

Notification.create!([
  {
    message: "New blog post: The Future of AI",
    read: false,
    title: "New Post",
    type: "info",
    link: "/blog/the-future-of-ai",
    notifiable_id: USER_ID,
    notifiable_type: "User",
    created_at: Time.current,
    updated_at: Time.current
  },
  {
    message: "You received a new message",
    read: false,
    title: "New Message",
    type: "info",
    link: "/conversations/#{conversation.id}",
    notifiable_id: USER_ID,
    notifiable_type: "User",
    created_at: Time.current,
    updated_at: Time.current
  }
])

puts "✅ Seeding completed successfully!"
