class Api::V1::User::OrganizationInvitationSerializer < ActiveModel::Serializer
  attributes :id, :organization_id, :account_id, :email
  attributes :invite_type, :role, :invitation_code, :display_invitation_code
  attributes :used_count, :max_uses
  attributes :created_at, :updated_at
  has_one :organization
end
