class Api::V1::User::ActivityQuestionSerializer < ActiveModel::Serializer
  attributes :id, :activity_id, :question_id
  attributes :created_at, :updated_at
  has_one :activity
  has_one :question
end
