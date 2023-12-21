class Curriculum < ApplicationRecord
  has_many :subjects, dependent: :destroy
  has_many :topics, through: :subjects
  has_many :papers, through: :subjects
  has_many :exams, through: :papers
  has_many :questions, through: :exams
  has_many :answers, through: :questions
  has_many :question_images, through: :questions
  has_many :question_topics, through: :questions

  validates :name, presence: true, uniqueness: { scope: :board, case_sensitive: false }
  validates :board, presence: true

  scope :query, ->(keyword) { where("name ILIKE :keyword OR board ILIKE :keyword", keyword: "%#{keyword}%") }
end
