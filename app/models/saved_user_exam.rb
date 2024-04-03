class SavedUserExam < ApplicationRecord
  belongs_to :user
  belongs_to :user_exam

  validates :user_exam_id, uniqueness: { scope: :user_id, case_sensitive: false }
end
