class Api::V1::Admin::GuessWordSubmissionGuessSerializer < ActiveModel::Serializer
  attributes :id, :guess_word_submission_id, :guess, :result

  attributes :created_at, :updated_at

  has_one :guess_word_submission
  has_one :guess_word
end
