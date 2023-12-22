class User < Account
  devise :database_authenticatable, :validatable, :registerable

  validates :name, presence: true

  scope :query, ->(keyword) { where('name ILIKE :keyword OR email ILIKE :keyword', keyword: "%#{keyword}%") }
end
