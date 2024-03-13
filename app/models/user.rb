class User < Account
  devise :database_authenticatable, :validatable, :registerable

  has_one :stripe_profile, dependent: :restrict_with_error
  has_many :subscriptions, dependent: :restrict_with_error
  has_many :challenge_submissions, dependent: :destroy
  has_many :submission_answers, dependent: :destroy
  has_one :active_subscription, -> { active }, class_name: 'Subscription'

  validates :name, presence: true

  scope :query, ->(keyword) { where('name ILIKE :keyword OR email ILIKE :keyword', keyword: "%#{keyword}%") }
end
