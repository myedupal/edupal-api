class Exam < ApplicationRecord
  belongs_to :paper

  has_many :questions, dependent: :destroy
  has_many :answers, through: :questions
  has_many :question_images, through: :questions
  has_many :question_topics, through: :questions

  validates :year, presence: true

  mount_base64_uploader :file, DocumentUploader
  mount_base64_uploader :marking_scheme, DocumentUploader
end
