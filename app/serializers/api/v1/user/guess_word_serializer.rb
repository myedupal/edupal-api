class Api::V1::User::GuessWordSerializer < ActiveModel::Serializer
  attributes :id, :subject_id, :description, :attempts, :reward_points
  attribute :answer_length
  # attribute :answer

  attributes :start_at, :end_at
  attributes :created_at, :updated_at

  has_one :subject
  # has_many :guess_word_submissions
  attribute :user_guess_word_submissions, if: -> { object.user_guess_word_submissions.present? } do
    ActiveModel::Serializer::CollectionSerializer.new(
      object.user_guess_word_submissions,
      serializer: Api::V1::User::GuessWordSubmissionSerializer,
      exclude_guess_word: true
    )
  end

  def answer_length
    object.answer.length
  end
end
