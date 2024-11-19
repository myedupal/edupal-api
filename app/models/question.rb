class Question < ApplicationRecord
  self.implicit_order_column = 'number'

  belongs_to :organization, optional: true
  belongs_to :subject
  belongs_to :exam, optional: true

  has_many :answers, dependent: :destroy
  has_many :question_images, dependent: :destroy
  has_many :question_topics, dependent: :destroy
  has_many :topics, -> { distinct }, through: :question_topics
  has_many :submission_answers, dependent: :destroy
  has_many :challenge_questions, dependent: :destroy
  has_many :activity_questions, dependent: :destroy
  has_many :user_exam_questions, dependent: :destroy
  has_many :point_activities, as: :activity, dependent: :destroy

  has_many :user_collection_questions, dependent: :destroy
  has_many :user_collections, through: :user_collection_questions
  attr_accessor :user_collections_preloaded

  accepts_nested_attributes_for :answers, allow_destroy: true, reject_if: proc { |attributes| attributes['text'].blank? && attributes['image'].blank? }
  accepts_nested_attributes_for :question_images, allow_destroy: true, reject_if: proc { |attributes| attributes['image'].blank? }
  accepts_nested_attributes_for :question_topics, allow_destroy: true, reject_if: proc { |attributes| attributes['topic_id'].blank? }

  enum question_type: { mcq: 'mcq', text: 'text' }, _default: 'text'

  scope :with_activity_presence, lambda { |activity_id|
    sql = <<~SQL.squish
      LEFT JOIN (
        SELECT DISTINCT question_id
        FROM activity_questions
        WHERE activity_id = '#{activity_id}'
      ) AS activity_question_presence ON activity_question_presence.question_id = questions.id
    SQL
    joins(sql).select('questions.*')
              .select('activity_question_presence.question_id IS NOT NULL AS activity_presence')
  }
  scope :have_topics, -> { joins(:topics).distinct }

  validates :subject, :exam, same_organization: true

  validates :number, presence: true, uniqueness: { scope: :exam_id }

  store_accessor :metadata, :topics_label

  before_validation :set_subject_id, if: -> { exam.present? }

  after_commit :flush_cache

  private

    def set_subject_id
      self.subject_id = exam.paper.subject_id
    end

    def flush_cache
      Rails.cache.delete("#{exam.paper.subject}:exams_filtering")
    end
end
