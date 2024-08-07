class Api::V1::Admin::ReferralActivitySerializer < ActiveModel::Serializer
  attributes :id, :user_id, :referral_source_id, :referral_source_type, :referral_type, :voided, :credit

  attributes :created_at, :updated_at

  has_one :user
  has_one :referral_source
end
