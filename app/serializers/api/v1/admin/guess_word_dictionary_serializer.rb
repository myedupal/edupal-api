class Api::V1::Admin::GuessWordDictionarySerializer < ActiveModel::Serializer
  attributes :id, :word

  attributes :created_at, :updated_at
end
