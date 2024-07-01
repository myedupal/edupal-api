class Api::V1::Admin::UserInfoSerializer < ActiveModel::Serializer
  attributes :id, :name, :active, :email
end
