class Api::V1::User::ChallengeSubmissionSerializer < ActiveModel::Serializer
  attributes :id, :status, :score, :total_score, :completion_seconds, :penalty_seconds, :submitted_at,
             :challenge_id, :user_id
  attributes :created_at, :updated_at
  has_one :challenge
  # has_one :user
  has_many :submission_answers
end
