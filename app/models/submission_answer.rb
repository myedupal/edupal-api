class SubmissionAnswer < ApplicationRecord
  belongs_to :challenge_submission, optional: true
  belongs_to :question
  belongs_to :user

  validates :answer, presence: true
  validate :question_belongs_to_challenge, if: -> { challenge_submission.present? }

  before_commit :evaluate, on: :create, if: -> { challenge_submission.blank? }
  before_validation :set_user_id, on: :create, if: -> { challenge_submission.present? }

  def evaluate
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

    update(is_correct: is_correct, score: score)
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
end
