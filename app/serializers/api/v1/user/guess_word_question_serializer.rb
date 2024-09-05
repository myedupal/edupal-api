class Api::V1::User::GuessWordQuestionSerializer < ActiveModel::Serializer
  attributes :id, :guess_word_pool_id
  attributes :word, :description
end
