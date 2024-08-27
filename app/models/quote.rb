class Quote < ApplicationRecord
  belongs_to :user
  belongs_to :created_by, class_name: 'Account'
  has_many :subscriptions
end
