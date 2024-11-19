class SubmissionAnswer < ApplicationRecord
  belongs_to :organization, optional: true
  belongs_to :submission
  belongs_to :question
  belongs_to :user

  validates :submission, same_organization: true
  validates :answer, presence: true
  validates :recorded_time, presence: true
  validates :question_id, uniqueness: { scope: :submission_id, case_sensitive: false }
  validate :question_belongs_to_challenge, if: -> { submission&.challenge&.present? }

  # before_commit :evaluate, on: :create, if: -> { submission.blank? }
  before_validation :set_user_id, on: :create, if: -> { submission.present? }

  def evaluate(force: false)
    return if evaluated_at.present? && !force
    return unless question.mcq?

    is_correct = question.answers.correct.exists?(text: answer)
    score = if !is_correct
              0
            elsif submission.challenge.present?
              submission.challenge
                        .challenge_questions
                        .find_by(question_id: question_id)
                        .score
            else
              Setting.answered_question_points
            end

    update(is_correct: is_correct, score: score, evaluated_at: Time.current)
  end

  private

    def set_user_id
      self.user_id = submission.user_id
    end

    def question_belongs_to_challenge
      return if question_id.blank?
      return if submission.challenge.challenge_questions.exists?(question_id: question_id)

      errors.add(:question, 'should belong to the challenge')
    end
end
