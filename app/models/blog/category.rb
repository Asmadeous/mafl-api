class Blog::Category < ApplicationRecord
    validates :name, presence: true, uniqueness: true
    validates :slug, presence: true, uniqueness: true
    has_many :posts, class_name: "Blog::Post", foreign_key: "category"

    before_validation :generate_slug, unless: :slug?

    private

    def generate_slug
      self.slug = name.parameterize
    end
end
