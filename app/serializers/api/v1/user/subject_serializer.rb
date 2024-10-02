class Api::V1::User::SubjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :code, :curriculum_id, :banner
  has_one :curriculum
  has_many :papers
end
