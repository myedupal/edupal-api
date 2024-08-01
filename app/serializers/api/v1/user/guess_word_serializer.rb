class Api::V1::User::GuessWordSerializer < ActiveModel::Serializer
  attributes :id, :subject_id, :description, :attempts, :reward_points
  attribute :answer_length
  attribute :answer, if: :completed_game?

  attributes :start_at, :end_at
  attributes :created_at, :updated_at

  has_one :subject
  # has_many :guess_word_submissions

  def answer_length
    object.answer.length
  end

  def completed_game?
    object.guess_word_submissions.find { |submission| submission.user_id == current_user.id }&.completed_at.present?
  end
end
