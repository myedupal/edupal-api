class Api::V1::User::PointActivitySerializer < ActiveModel::Serializer
  attributes :id, :action_type, :points, :activity_id, :activity_type,
             :account_id
  attributes :created_at, :updated_at
  has_one :activity
end
