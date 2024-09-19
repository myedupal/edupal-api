class UserExam < ApplicationRecord
  include NanoidGenerator

  belongs_to :created_by, class_name: 'Account'
  belongs_to :subject

  validates :title, presence: true

  has_many :user_exam_questions, dependent: :destroy
  has_many :questions, through: :user_exam_questions
  has_many :saved_user_exams, dependent: :destroy
  has_many :submissions, dependent: :destroy

  accepts_nested_attributes_for :user_exam_questions, allow_destroy: true, reject_if: :all_blank
end
