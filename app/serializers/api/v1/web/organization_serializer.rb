class Api::V1::Web::OrganizationSerializer < ActiveModel::Serializer
  attributes :id
  attributes :title, :description, :icon_image, :banner_image
  attributes :status
  attributes :created_at, :updated_at
end
