class GiftCard < ApplicationRecord
  belongs_to :plan
  belongs_to :created_by, class_name: 'Admin'

  validates :redemption_limit, numericality: { greater_than: 0 }

  before_create :generate_code

  scope :query, ->(keyword) { where('name ILIKE ?', "%#{keyword}%") }

  private

    def generate_code
      self.code = SecureRandom.base36(6)
    end
end
