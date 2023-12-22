class Api::V1::User::UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :active, :email
  attributes :created_at, :updated_at

  has_one :stripe_profile
end
