class Api::V1::Admin::ChallengeQuestionSerializer < ActiveModel::Serializer
  attributes :id, :question_id, :challenge_id, :score, :display_order
  attributes :created_at, :updated_at
  has_one :challenge
  has_one :question
end
