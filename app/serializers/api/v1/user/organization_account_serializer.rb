class Api::V1::User::OrganizationAccountSerializer < ActiveModel::Serializer
  attributes :id, :organization_id, :account_id, :role

  attributes :created_at, :updated_at

  has_one :account
end
