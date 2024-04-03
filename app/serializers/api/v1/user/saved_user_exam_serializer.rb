class Api::V1::User::SavedUserExamSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :user_exam_id
  attributes :created_at, :updated_at
  # has_one :user
  has_one :user_exam
end
