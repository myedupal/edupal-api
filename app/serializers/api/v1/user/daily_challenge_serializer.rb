class Api::V1::User::DailyChallengeSerializer < ActiveModel::Serializer
  attributes :id, :title, :challenge_type, :start_at, :end_at, :reward_points,
             :reward_type, :penalty_seconds, :subject_id, :user_submission_count,
             :user_success_submission_count, :challenge_questions_count
  attributes :created_at, :updated_at
  has_one :subject
  has_many :challenge_questions
  has_many :questions
end
