class Api::V1::Admin::AnswerSerializer < ActiveModel::Serializer
  attributes :id, :text, :image
  attributes :created_at, :updated_at
  has_one :question
end
