class Api::V1::Admin::PaperSerializer < ActiveModel::Serializer
  attributes :id, :name
  attributes :created_at, :updated_at
  has_one :subject
end
