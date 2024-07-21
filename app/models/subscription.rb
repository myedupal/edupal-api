class Subscription < ApplicationRecord
  belongs_to :plan
  belongs_to :price, optional: true
  belongs_to :user
  belongs_to :created_by, class_name: 'Account'

  scope :active, lambda {
                   where(status: %w[active completed])
                     .where('start_at <= ?', Time.current)
                     .where('end_at >= ? OR end_at IS NULL', Time.current)
                 }

  validates :start_at, presence: true
end
