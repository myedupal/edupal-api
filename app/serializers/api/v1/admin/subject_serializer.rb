class Api::V1::Admin::SubjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :code
  attributes :created_at, :updated_at
  has_one :curriculum
  has_many :papers
end
