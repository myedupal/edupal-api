class Api::V1::User::StripeProfileSerializer < ActiveModel::Serializer
  attributes :id, :customer_id, :payment_method_id, :current_setup_intent_id
  attributes :created_at, :updated_at
end
