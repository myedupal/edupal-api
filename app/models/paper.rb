class Paper < ApplicationRecord
  belongs_to :organization, optional: true
  belongs_to :subject

  has_many :exams, dependent: :destroy
  has_many :questions, through: :exams
  has_many :answers, through: :questions
  has_many :question_images, through: :questions
  has_many :question_topics, through: :questions
  has_many :activity_papers, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :subject_id, case_sensitive: false }
  validates :subject, same_organization: true

  scope :has_mcq_questions, -> { joins(exams: :questions).where(questions: { question_type: 'mcq' }).distinct }
end
