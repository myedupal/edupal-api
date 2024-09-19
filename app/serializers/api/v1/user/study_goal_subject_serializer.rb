class Api::V1::User::StudyGoalSubjectSerializer < ActiveModel::Serializer
  attributes :id, :study_goal_id, :subject_id

  attributes :created_at, :updated_at

  has_one :subject
end
