class UserExamQuestion < ApplicationRecord
  belongs_to :user_exam
  belongs_to :question

  validates :question_id, uniqueness: { scope: :user_exam_id, case_sensitive: false }
end
