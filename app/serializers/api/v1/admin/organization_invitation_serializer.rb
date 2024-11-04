class Api::V1::Admin::OrganizationInvitationSerializer < ActiveModel::Serializer
  attributes :id, :organization_id, :created_by_id, :account_id, :email
  attributes :invite_type, :role, :invitation_code, :display_invitation_code
  attributes :used_count, :max_uses
  attributes :created_at, :updated_at

  has_one :organization
  has_one :created_by
  has_one :account
end
