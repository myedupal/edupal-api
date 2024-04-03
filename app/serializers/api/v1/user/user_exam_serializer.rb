class Api::V1::User::UserExamSerializer < ActiveModel::Serializer
  attributes :id, :title, :is_public, :nanoid, :created_by_id, :subject_id
  attributes :created_at, :updated_at
  has_one :created_by, serializer: Api::V1::User::UserInfoSerializer
  has_one :subject
  has_many :questions
  has_many :user_exam_questions
end
