class Api::V1::Admin::SubmissionAnswerSerializer < ActiveModel::Serializer
  attributes :id, :answer, :is_correct, :score, :challenge_submission_id,
             :question_id, :user_id, :evaluated_at, :recorded_time
  attributes :created_at, :updated_at
  has_one :challenge_submission
  has_one :question
  has_one :user
end
