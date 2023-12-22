class Api::V1::User::CurriculumSerializer < ActiveModel::Serializer
  attributes :id, :name, :board, :display_order
end
