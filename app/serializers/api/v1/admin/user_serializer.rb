class Api::V1::Admin::UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :active, :email, :points,
             :oauth2_provider, :oauth2_sub, :oauth2_profile_picture_url
  attributes :created_at, :updated_at

  has_one :stripe_profile
end
