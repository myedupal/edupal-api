class Api::V1::Web::OrganizationInvitationSerializer < ActiveModel::Serializer
  attributes :id, :organization_id
  attributes :invite_type, :role, :invitation_code
  attributes :created_at, :updated_at
  has_one :organization
end
