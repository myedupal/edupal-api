class Api::V1::Web::CurriculumSerializer < ActiveModel::Serializer
  attributes :id, :name, :board, :display_order
  has_many :subjects
end
