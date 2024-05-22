class Subject < ApplicationRecord
  belongs_to :curriculum

  has_many :topics, dependent: :destroy
  has_many :papers, dependent: :destroy
  has_many :exams, through: :papers
  has_many :questions
  has_many :exam_questions, through: :exams, class_name: 'Question', source: :questions
  has_many :answers, through: :questions
  has_many :question_images, through: :questions
  has_many :question_topics, through: :questions
  has_many :challenges, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :curriculum_id, case_sensitive: false }
  # validates :code, uniqueness: { scope: :curriculum_id, case_sensitive: false }, allow_nil: true

  scope :query, ->(keyword) { where('name ILIKE :keyword OR code ILIKE :keyword', keyword: "%#{keyword}%") }
  scope :published, -> { where(is_published: true) }
  scope :has_mcq_questions, -> { joins(:questions).where(questions: { question_type: 'mcq' }).distinct }
end
