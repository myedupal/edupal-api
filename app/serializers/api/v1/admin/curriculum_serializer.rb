class Api::V1::Admin::CurriculumSerializer < ActiveModel::Serializer
  attributes :id, :name, :board, :display_order
  attributes :created_at, :updated_at
end
