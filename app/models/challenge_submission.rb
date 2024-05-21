class ChallengeSubmission < ApplicationRecord
  include AASM
  belongs_to :challenge
  belongs_to :user

  has_many :submission_answers, dependent: :nullify
  has_many :point_activities, as: :activity, dependent: :destroy

  accepts_nested_attributes_for :submission_answers, allow_destroy: true, reject_if: :reject_submission_answer_attributes?

  before_save :evaluate_answers, if: -> { submitted? }
  after_commit :update_user_streaks, if: -> { saved_change_to_status? && submitted? }
  after_commit :create_or_update_daily_challenge_point_activity, if: -> { saved_change_to_status? && submitted? }

  aasm column: :status, whiny_transitions: false, timestamps: true do
    state :pending, initial: true
    state :submitted, :failed

    event :submit do
      transitions from: :pending, to: :submitted,
                  guard: [:within_challenge_time?]
      transitions from: :pending, to: :failed
    end
  end

  private

    def reject_submission_answer_attributes?(attributes)
      attributes['answer'].blank? || attributes['question_id'].blank?
    end

    def within_challenge_time?
      challenge.start_at <= Time.current && challenge.end_at >= Time.current
    end

    def evaluate_answers
      attempted = ChallengeSubmission.submitted
                                     .where(user_id: user_id, challenge_id: challenge_id)
                                     .count
      submission_answers.each(&:evaluate)
      self.score = submission_answers.sum(:score)
      self.total_score = challenge.challenge_questions.sum(:score)
      self.penalty_seconds = attempted * challenge.penalty_seconds
      self.completion_seconds = (submitted_at - challenge.start_at).to_i + penalty_seconds
    end

    def update_user_streaks
      return unless is_user_first_full_score_daily_challenge_submission?

      user.update(
        daily_streak: user.daily_streak + 1,
        maximum_streak: [user.maximum_streak, user.daily_streak + 1].max
      )
    end

    def is_user_first_full_score_daily_challenge_submission?
      first_submission = ChallengeSubmission.joins(:challenge)
                                            .submitted
                                            .where(challenge: { challenge_type: Challenge.challenge_types[:daily] })
                                            .where(user_id: user_id)
                                            .where('score > 0')
                                            .where('score = total_score')
                                            .order(submitted_at: :asc)
                                            .first
      first_submission.nil? || first_submission.id == id
    end

    def create_or_update_daily_challenge_point_activity
      return unless challenge.daily?
      return unless score == total_score

      point_activity = user.point_activities.find_or_initialize_by(
        action_type: PointActivity.action_types[:daily_challenge],
        activity_id: id,
        activity_type: self.class.name
      )
      point_activity.points = score
      point_activity.save!
    end
end
