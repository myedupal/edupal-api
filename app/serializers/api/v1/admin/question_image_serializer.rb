class Api::V1::Admin::QuestionImageSerializer < ActiveModel::Serializer
  attributes :id, :image, :display_order, :question_id
  attributes :created_at, :updated_at
  has_one :question
end
