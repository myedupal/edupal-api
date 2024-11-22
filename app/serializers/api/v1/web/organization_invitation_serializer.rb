class Api::V1::Web::OrganizationInvitationSerializer < ActiveModel::Serializer
  attributes :id, :organization_id
  attributes :invite_type, :role, :invitation_code, :display_invitation_code
  attributes :used_count, :max_uses
  attributes :created_at, :updated_at
  has_one :organization
end
