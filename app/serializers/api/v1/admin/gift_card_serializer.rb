class Api::V1::Admin::GiftCardSerializer < ActiveModel::Serializer
  attributes :id, :name, :remark, :redemption_limit, :redemption_count,
             :expires_at, :code, :plan_id
  attributes :created_at, :updated_at
  has_one :plan
  has_one :created_by, serializer: Api::V1::Admin::UserInfoSerializer
end
