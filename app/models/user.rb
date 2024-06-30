class User < Account
  devise :database_authenticatable, :validatable, :registerable

  belongs_to :selected_curriculum, class_name: 'Curriculum', optional: true

  has_one :stripe_profile, dependent: :restrict_with_error
  has_many :subscriptions, dependent: :restrict_with_error
  has_many :submissions, dependent: :destroy
  has_many :submission_answers, dependent: :destroy
  has_one :active_subscription, -> { active }, class_name: 'Subscription'
  has_many :activities, dependent: :destroy
  has_many :saved_user_exams, dependent: :destroy
  has_many :daily_check_ins, dependent: :destroy

  validates :name, presence: true

  scope :query, ->(keyword) { where('name ILIKE :keyword OR email ILIKE :keyword', keyword: "%#{keyword}%") }
end
