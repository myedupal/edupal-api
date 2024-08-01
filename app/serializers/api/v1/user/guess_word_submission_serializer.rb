class Api::V1::User::GuessWordSubmissionSerializer < ActiveModel::Serializer
  attributes :id, :guess_word_id, :user_id, :status
  attributes :guesses_count

  attributes :completed_at
  attributes :created_at, :updated_at

  # has_one :user
  has_one :guess_word
  has_many :guesses
end
