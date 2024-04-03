class Api::V1::User::UserExamQuestionSerializer < ActiveModel::Serializer
  attributes :id, :user_exam_id, :question_id
  attributes :created_at, :updated_at
  has_one :user_exam
  has_one :question
end
