class Submission < ApplicationRecord
  include AASM
  belongs_to :challenge, optional: true
  belongs_to :user_exam, optional: true
  belongs_to :user

  has_many :submission_answers, dependent: :destroy
  has_many :point_activities, as: :activity, dependent: :destroy

  accepts_nested_attributes_for :submission_answers, allow_destroy: true, reject_if: :reject_submission_answer_attributes?

  enum mcq_type: { yearly: 'yearly', topical: 'topical' }

  validates :title, presence: true, if: -> { challenge.blank? }
  validates :mcq_type, presence: true, if: -> { challenge.blank? }
  validates :mcq_type, absence: true, if: -> { challenge.present? }

  scope :daily_challenge, -> { joins(:challenge).where(challenges: { challenge_type: Challenge.challenge_types[:daily] }) }
  scope :mcq, -> { where(challenge_id: nil).where(user_exam_id: nil) }
  scope :is_user_exam, lambda { |bool|
    if bool
      where.not(user_exam_id: nil)
    else
      where(user_exam_id: nil)
    end
  }

  before_save :evaluate_answers, :calculate_total_submission_answers, :calculate_score, :calculate_completion_seconds, if: -> { submitted? }
  after_commit :update_user_streaks, if: -> { saved_change_to_status? && submitted? && challenge&.daily? }
  after_commit :create_or_update_daily_challenge_point_activity, if: -> { saved_change_to_status? && submitted? && challenge&.daily? }
  after_commit :create_answered_question_point_activity, if: -> { submitted? && challenge.blank? }

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
      return true if challenge.nil?
      return true if challenge.start_at <= Time.current && challenge.end_at >= Time.current

      errors.add(:challenge, 'is not available for submission')
      false
    end

    def evaluate_answers
      submission_answers.each(&:evaluate)
    end

    def calculate_total_submission_answers
      self.total_submitted_answers = submission_answers.size
      self.total_correct_answers = submission_answers.select(&:is_correct?).size
    end

    def calculate_score
      self.score = submission_answers.sum(:score)
      self.total_score = score

      return if challenge.blank?

      self.total_score = challenge.challenge_questions.sum(:score)
    end

    def calculate_completion_seconds
      if challenge.present? && challenge.contest?
        attempted = Submission.submitted
                              .where(user_id: user_id, challenge_id: challenge_id)
                              .where.not(id: id)
                              .count
        self.penalty_seconds = attempted * challenge.penalty_seconds
        self.completion_seconds = (submitted_at - challenge.start_at).to_i + penalty_seconds
      else
        self.completion_seconds = (submitted_at - created_at).to_i
      end
    end

    def update_user_streaks
      return unless is_user_first_full_score_daily_challenge_submission?

      user.update(
        daily_streak: user.daily_streak + 1,
        maximum_streak: [user.maximum_streak, user.daily_streak + 1].max
      )
    end

    def is_user_first_full_score_daily_challenge_submission?
      first_submission = Submission.joins(:challenge)
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
      return unless score == total_score

      point_activity = user.point_activities.find_or_initialize_by(
        action_type: PointActivity.action_types[:daily_challenge],
        activity_id: challenge_id,
        activity_type: challenge.class.name
      )
      point_activity.points = score
      point_activity.save!
    end

    def create_answered_question_point_activity
      user.point_activities.find_or_create_by(
        action_type: :answered_question,
        activity_id: id,
        activity_type: self.class.name
      ) do |point_activity|
        point_activity.points = score
      end
    end
end
