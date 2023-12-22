class Api::V1::User::PaperSerializer < ActiveModel::Serializer
  attributes :id, :name, :subject_id
  has_one :subject
end
