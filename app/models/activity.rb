class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :subject
  belongs_to :exam, optional: true

  has_many :activity_questions, dependent: :destroy
  has_many :activity_topics, dependent: :destroy
  has_many :topics, through: :activity_topics
  has_many :activity_papers, dependent: :destroy
  has_many :papers, through: :activity_papers

  enum activity_type: { yearly: 'yearly', topical: 'topical' }

  validates :exam_id, presence: true, if: -> { yearly? }
  validates :exam_id, absence: true, if: -> { topical? }

  before_validation :set_subject_id, on: :create, if: -> { exam_id.present? }

  store_accessor :metadata, [:sort_by, :sort_order, :page, :items,
                             :years, :seasons, :zones, :levels, :question_type, :numbers,
                             :last_question_id, :last_position]

  def questions_count
    return 0 if yearly?

    Rails.cache.fetch("activity/#{id}/questions_count", expires_in: 1.hour) do
      questions = Question.where(subject_id: subject_id)
      questions = questions.joins(:topics).where(topics: { id: topic_ids }) if topic_ids.any?
      questions = questions.joins(:exam).where(exam: { paper_id: paper_ids }) if paper_ids.any?
      questions = questions.joins(:exam).where(exam: { year: years }) if years&.any?
      questions = questions.joins(:exam).where(exam: { season: seasons }) if seasons&.any?
      questions = questions.joins(:exam).where(exam: { zone: zones }) if zones&.any?
      questions = questions.joins(:exam).where(exam: { level: levels }) if levels&.any?
      questions = questions.where(question_type: question_type) if question_type.present?
      questions = questions.where(number: numbers) if numbers&.any?
      questions.distinct(:id).count
    end
  end

  private

    def set_subject_id
      self.subject_id = exam.paper.subject_id
    end
end
