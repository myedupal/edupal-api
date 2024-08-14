class Api::V1::User::UserCollectionQuestionSerializer < ActiveModel::Serializer
  attributes :id, :user_collection_id, :question_id
  attributes :created_at, :updated_at
  has_one :user_collection
  has_one :question
end
