



# db/seeds.rb
category1 = Blog::Category.create!(name: "Tech", slug: "tech", description: "Tech topics")
tag1 = Blog::Tag.create!(name: "ruby", slug: "ruby")
tag2 = Blog::Tag.create!(name: "rails", slug: "rails")
employee = Employee.create!(full_name: "Admin", email: "admin#{Time.now.to_i}@example.com", password: "password123")

post1 = Blog::Post.create!(
  title: "Ruby Tips",
  slug: "ruby-tips",
  content: "Learn Ruby!",
  excerpt: "Top Ruby tips",
  category: category1,
  employee: employee,
  status: "published",
  published_at: Time.current
)
post1.tags << [ tag1, tag2 ]

post2 = Blog::Post.create!(
  title: "Rails Guide",
  slug: "rails-guide",
  content: "Master Rails!",
  excerpt: "Rails basics",
  category: category1,
  employee: employee,
  status: "published",
  published_at: Time.current
)
post2.tags << tag1
