class Subscription < ApplicationRecord
  belongs_to :plan
  belongs_to :price, optional: true
  belongs_to :user
  belongs_to :created_by, class_name: 'Account'

  has_many :referred_activities, class_name: 'ReferralActivity', as: :referral_source, dependent: :nullify

  scope :active, lambda {
                   where(status: %w[active completed])
                     .where('start_at <= ?', Time.current)
                     .where('end_at >= ? OR end_at IS NULL', Time.current)
                 }

  validates :start_at, presence: true

  after_commit :create_referral_activity

  private

    def create_referral_activity
      return if status != 'active'
      return if user.referred_by.blank?
      return if referred_activities.present?
      return unless price.present?

      referred_activities.create!(
        user: user.referred_by,
        referral_type: :subscription,
        credit_cents: price.amount_cents * plan.referral_fee_percentage / 100
      )
    end
end
