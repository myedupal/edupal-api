class Exam < ApplicationRecord
  belongs_to :paper

  has_many :questions, dependent: :destroy
  has_many :answers, through: :questions
  has_many :question_images, through: :questions
  has_many :question_topics, through: :questions

  validates :year, presence: true, uniqueness: { scope: [:paper_id, :season, :zone, :level], case_sensitive: false }

  mount_base64_uploader :file, DocumentUploader
  mount_base64_uploader :marking_scheme, DocumentUploader

  scope :has_mcq_questions, -> { joins(:questions).where(questions: { question_type: 'mcq' }) }

  after_commit :flush_cache

  private

    def flush_cache
      Rails.cache.delete("#{paper.subject}:exams_filtering")
    end
end
