class Api::V1::Admin::SubmissionSerializer < ActiveModel::Serializer
  attributes :id, :status, :score, :total_score, :completion_seconds, :penalty_seconds, :submitted_at,
             :challenge_id, :user_exam_id, :user_id, :title, :total_submitted_answers, :total_correct_answers, :mcq_type
  attributes :created_at, :updated_at
  has_one :challenge
  has_one :user_exam
  has_one :user
  has_many :submission_answers
end
