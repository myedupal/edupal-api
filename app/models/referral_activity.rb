class ReferralActivity < ApplicationRecord
  belongs_to :user
  belongs_to :referral_source, polymorphic: true, optional: true

  monetize :credit_cents

  enum referral_type: {
    signup: 'Signup',
    subscription: 'Subscription'
  }

  after_commit :update_account_credits

  def nullify!
    update(voided: true)
  end

  def revalidate!
    update(voided: false)
  end

  private

    def update_account_credits
      user.update(referred_credit_cents: user.referral_activities.where(voided: false).sum(:credit_cents))
    end
end
