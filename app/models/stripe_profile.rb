class StripeProfile < ApplicationRecord
  belongs_to :user

  validates :customer_id, uniqueness: { case_sensitive: false }, allow_nil: true
  validates :user_id, uniqueness: { case_sensitive: false }
end
