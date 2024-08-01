class Api::V1::Admin::GuessWordSerializer < ActiveModel::Serializer
  attributes :id, :subject_id, :answer, :description, :attempts, :reward_points
  attribute :guess_word_submissions_count

  attributes :start_at, :end_at
  attributes :created_at, :updated_at

  has_one :subject
  has_many :guess_word_submissions
end
