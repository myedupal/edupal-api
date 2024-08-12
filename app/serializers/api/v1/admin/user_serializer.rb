class Api::V1::Admin::UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :active, :email, :points, :phone_number,
             :oauth2_provider, :oauth2_sub, :oauth2_iss, :oauth2_aud, :oauth2_profile_picture_url,
             :daily_streak, :maximum_streak, :selected_curriculum_id
  attributes :created_at, :updated_at

  has_one :stripe_profile
  has_one :selected_curriculum
end
