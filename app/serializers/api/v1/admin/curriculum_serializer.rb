class Api::V1::Admin::CurriculumSerializer < ActiveModel::Serializer
  attributes :id, :organization_id, :name, :board, :display_order, :is_published
  attributes :created_at, :updated_at
end
