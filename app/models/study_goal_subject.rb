class StudyGoalSubject < ApplicationRecord
  belongs_to :study_goal
  belongs_to :subject

  validate :curriculum_must_match, if: -> { subject.present? && study_goal.present? }

  def curriculum_must_match
    errors.add(:subject, "must match the study goal's curriculum") if subject.curriculum_id != study_goal.curriculum_id
  end
end
