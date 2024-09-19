class Api::V1::User::UserCollectionSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :curriculum_id
  attributes :collection_type, :title, :description, :questions_count

  attributes :created_at, :updated_at

  has_many :user_collection_questions, unless: -> { instance_options[:skip_questions] }
  # has_many :questions
end
