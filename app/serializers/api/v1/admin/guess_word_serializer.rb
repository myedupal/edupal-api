class Api::V1::Admin::GuessWordSerializer < ActiveModel::Serializer
  attributes :id, :organization_id, :subject_id, :answer, :description, :attempts, :reward_points
  attribute :guess_word_submissions_count

  attributes :start_at, :end_at
  attributes :created_at, :updated_at

  has_one :subject
  has_many :guess_word_submissions

  attribute :completed_count, if: :with_reports?
  attribute :avg_guesses_count, if: :with_reports?
  attribute :in_progress_count, if: :with_reports?
  attribute :success_count, if: :with_reports?
  attribute :expired_count, if: :with_reports?
  attribute :failed_count, if: :with_reports?

  def with_reports?
    instance_options[:with_reports]
  end
end
