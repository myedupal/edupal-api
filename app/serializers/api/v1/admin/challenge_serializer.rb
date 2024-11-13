class Api::V1::Admin::ChallengeSerializer < ActiveModel::Serializer
  attributes :id, :organization_id, :title, :challenge_type, :start_at, :end_at, :reward_points,
             :reward_type, :penalty_seconds, :subject_id, :is_published, :banner
  attributes :created_at, :updated_at
  has_one :subject
  has_many :challenge_questions
  has_many :questions
end
