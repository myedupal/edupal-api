class SubmissionAnswer < ApplicationRecord
  belongs_to :challenge_submission, optional: true
  belongs_to :question
  belongs_to :user

  validates :answer, presence: true
  validates :recorded_time, presence: true
  validate :question_belongs_to_challenge, if: -> { challenge_submission.present? }

  before_commit :evaluate, on: :create, if: -> { challenge_submission.blank? }
  before_validation :set_user_id, on: :create, if: -> { challenge_submission.present? }
  after_commit :create_answered_question_point_activity, on: :create, if: -> { challenge_submission.blank? }

  def evaluate(force: false)
    return if evaluated_at.present? && !force
    return unless question.mcq?

    is_correct = question.answers.exists?(text: answer)
    score = if challenge_submission.present? && is_correct
              challenge_submission.challenge
                                  .challenge_questions
                                  .find_by(question_id: question_id)
                                  .score
            else
              0
            end

    update(is_correct: is_correct, score: score, evaluated_at: Time.current)
  end

  private

    def set_user_id
      self.user_id = challenge_submission.user_id
    end

    def question_belongs_to_challenge
      return if question_id.blank?
      return if challenge_submission.challenge.challenge_questions.exists?(question_id: question_id)

      errors.add(:question, 'should belong to the challenge')
    end

    def create_answered_question_point_activity
      return unless is_correct

      user.point_activities.find_or_create_by(
        action_type: :answered_question,
        activity_id: question_id,
        activity_type: question.class.name
      ) do |point_activity|
        point_activity.points = Setting.answered_question_points
      end
    end
end
