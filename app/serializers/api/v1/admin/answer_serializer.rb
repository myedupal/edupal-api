class Api::V1::Admin::AnswerSerializer < ActiveModel::Serializer
  attributes :id, :text, :image, :question_id, :display_order, :is_correct, :description
  attributes :created_at, :updated_at
  has_one :question
end
