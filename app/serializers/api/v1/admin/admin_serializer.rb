class Api::V1::Admin::AdminSerializer < ActiveModel::Serializer
  attributes :id, :name, :active, :email
  attributes :created_at, :updated_at
end
