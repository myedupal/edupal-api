class Admin < Account
  devise :database_authenticatable, :validatable

  validates :name, presence: true

  scope :query, ->(keyword) { where('name ILIKE :keyword OR email ILIKE :keyword', keyword: "%#{keyword}%") }
end
