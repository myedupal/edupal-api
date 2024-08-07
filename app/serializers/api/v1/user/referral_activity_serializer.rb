class Api::V1::User::ReferralActivitySerializer < ActiveModel::Serializer
  attributes :id, :user_id, :referral_type, :voided, :credit

  attributes :created_at, :updated_at
end
