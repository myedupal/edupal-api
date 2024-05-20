class Api::V1::Admin::SubjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :code, :curriculum_id, :is_published
  attributes :created_at, :updated_at
  has_one :curriculum
  has_many :papers
end
