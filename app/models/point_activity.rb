class PointActivity < ApplicationRecord
  belongs_to :account
  belongs_to :activity, polymorphic: true, optional: true

  enum action_type: {
    redeem: 'Redeem',
    daily_challenge: 'DailyChallenge',
    daily_check_in: 'DailyCheckIn',
    answered_question: 'AnsweredQuestion'
  }, _default: :answered_question

  validates :points, numericality: { other_than: 0, only_integer: true }

  after_commit :update_account_points, on: :create

  private

    def update_account_points
      account.update(points: account.point_activities.sum(:points))
    end
end
