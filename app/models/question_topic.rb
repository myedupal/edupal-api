class QuestionTopic < ApplicationRecord
  belongs_to :question
  belongs_to :topic

  validates :question_id, uniqueness: { scope: :topic_id, case_sensitive: false }
end
