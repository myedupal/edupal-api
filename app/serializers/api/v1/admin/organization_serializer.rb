class Api::V1::Admin::OrganizationSerializer < ActiveModel::Serializer
  attributes :id, :owner_id
  attributes :title, :description, :icon_image, :banner_image
  attributes :status, :current_headcount, :maximum_headcount

  attributes :created_at, :updated_at

  has_many :organization_accounts
end
