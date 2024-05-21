class DailyCheckIn < ApplicationRecord
  belongs_to :user

  has_many :point_activities, as: :activity, dependent: :destroy

  validates :date, uniqueness: { scope: :user_id }, presence: true
end
