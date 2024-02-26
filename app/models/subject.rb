class Subject < ApplicationRecord
  belongs_to :curriculum

  has_many :topics, dependent: :destroy
  has_many :papers, dependent: :destroy
  has_many :exams, through: :papers
  has_many :questions, through: :exams
  has_many :answers, through: :questions
  has_many :question_images, through: :questions
  has_many :question_topics, through: :questions

  validates :name, presence: true, uniqueness: { scope: :curriculum_id, case_sensitive: false }
  # validates :code, uniqueness: { scope: :curriculum_id, case_sensitive: false }, allow_nil: true

  scope :query, ->(keyword) { where('name ILIKE :keyword OR code ILIKE :keyword', keyword: "%#{keyword}%") }
end
