class ChallengeQuestion < ApplicationRecord
  belongs_to :challenge
  belongs_to :question

  validates :question_id, uniqueness: { scope: :challenge_id, message: 'should be unique for a challenge' }
  validates :display_order, presence: true
  validates :score, presence: true
end
