class StudyGoal < ApplicationRecord
  belongs_to :user
  belongs_to :curriculum

  has_many :study_goal_subjects, dependent: :destroy
  accepts_nested_attributes_for :study_goal_subjects, allow_destroy: true
  has_many :subjects, through: :study_goal_subjects

  validates :a_grade_count, presence: true
  validates :curriculum_id, uniqueness: { scope: :user_id }
end
