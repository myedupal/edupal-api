class Api::V1::User::OrganizationSerializer < ActiveModel::Serializer
  attributes :id, :owner_id
  attributes :title, :description, :icon_image, :banner_image
  attributes :status, :current_headcount
  attributes :created_at, :updated_at
end
