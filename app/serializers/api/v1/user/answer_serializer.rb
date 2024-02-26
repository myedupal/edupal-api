class Api::V1::User::AnswerSerializer < ActiveModel::Serializer
  attributes :id, :text, :image, :question_id, :display_order
  attributes :created_at, :updated_at
  has_one :question
end
