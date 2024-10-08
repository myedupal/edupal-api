class User < Account
  devise :database_authenticatable, :validatable, :registerable

  belongs_to :selected_curriculum, class_name: 'Curriculum', optional: true
  has_many :study_goals, dependent: :destroy do
    def current
      find_by(curriculum: proxy_association.owner.selected_curriculum)
    end
  end

  has_one :stripe_profile, dependent: :restrict_with_error
  has_many :subscriptions, dependent: :restrict_with_error
  has_many :active_subscriptions, -> { active }, class_name: 'Subscription' do
    def for_plan(plan:)
      where(plan: plan)
    end
  end
  has_many :quotes, dependent: :restrict_with_error

  has_many :submissions, dependent: :destroy
  has_many :submission_answers, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :saved_user_exams, dependent: :destroy
  has_many :daily_check_ins, dependent: :destroy

  belongs_to :referred_by, class_name: 'User', optional: true, counter_cache: :referred_count
  has_many :referred_users, class_name: 'User', foreign_key: 'referred_by_id', counter_cache: :referred_count
  has_many :referral_activities, dependent: :destroy
  has_many :referred_activities, class_name: 'ReferralActivity', as: :referral_source, dependent: :nullify

  monetize :referred_credit_cents

  validates :name, presence: true

  scope :query, ->(keyword) { where('name ILIKE :keyword OR email ILIKE :keyword OR nanoid ILIKE :keyword', keyword: "%#{keyword}%") }

  def update_referral(referral_code)
    if referred_by.present?
      errors.add(:referral_code, 'Already have a referral code')
      return false
    end

    if created_at < 1.day.ago
      errors.add(:referral_code, 'Only new account can set referral code')
      return false
    end

    if referral_code.blank?
      errors.add(:referral_code, 'Missing referral code')
      return false
    end

    referring_user = User.where(nanoid: referral_code).first
    if referring_user.blank? || referring_user == self
      errors.add(:referral_code, 'Invalid referral code')
      return false
    end

    transaction do
      update(referred_by: referring_user)

      referred_activities.create(
        user: referring_user,
        referral_type: :signup,
        credit_cents: Setting.referral_signup_credit_cents
      )
    end
    true
  end
end
