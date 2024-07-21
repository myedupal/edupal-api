class GiftCard < ApplicationRecord
  belongs_to :plan
  belongs_to :created_by, class_name: 'Admin'

  validates :redemption_limit, numericality: { greater_than: 0 }

  before_create :generate_code

  scope :query, ->(keyword) { where('name ILIKE ?', "%#{keyword}%") }

  def redeemable?
    redemption_limit.positive?
  end

  def redeem!
    increment!(:redemption_count)
  end

  def expired?
    expires_at.present? && expires_at < Time.zone.now
  end

  private

    def generate_code
      self.code = SecureRandom.base36(6)
    end
end
