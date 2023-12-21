class Paper < ApplicationRecord
  belongs_to :subject

  has_many :exams, dependent: :destroy
  has_many :questions, through: :exams
  has_many :answers, through: :questions
  has_many :question_images, through: :questions
  has_many :question_topics, through: :questions

  validates :name, presence: true, uniqueness: { scope: :subject_id, case_sensitive: false }
end
