class Topic < ApplicationRecord
  belongs_to :organization, optional: true
  belongs_to :subject

  has_many :question_topics, dependent: :destroy
  has_many :questions, through: :question_topics
  has_many :activity_topics, dependent: :destroy

  validates :subject, same_organization: true
  validates :name, presence: true, uniqueness: { scope: :subject_id, case_sensitive: false }

  scope :query, ->(keyword) { where('name ILIKE :keyword', keyword: "%#{keyword}%") }
end
