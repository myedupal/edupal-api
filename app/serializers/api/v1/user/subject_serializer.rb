class Api::V1::User::SubjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :code, :curriculum_id
  has_one :curriculum
  has_many :papers
end
