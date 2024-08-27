class Api::V1::User::QuoteSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :created_by_id, :stripe_quote_id, :status,
             :quote_expire_at
  attributes :created_at, :updated_at

  has_many :subscriptions
  # has_one :user
  # has_one :created_by
end
