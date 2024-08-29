class Api::V1::User::StudyGoalSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :curriculum_id
  attributes :a_grade_count

  attributes :created_at, :updated_at

  has_one :curriculum
  has_many :study_goal_subjects, unless: -> { instance_options[:skip_subjects] }
  # has_many :subjects
end
