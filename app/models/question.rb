class Question < ApplicationRecord
  self.implicit_order_column = 'number'

  belongs_to :exam, optional: true

  has_many :answers, dependent: :destroy
  has_many :question_images, dependent: :destroy
  has_many :question_topics, dependent: :destroy
  has_many :topics, -> { distinct }, through: :question_topics

  accepts_nested_attributes_for :answers, allow_destroy: true, reject_if: proc { |attributes| attributes['text'].blank? && attributes['image'].blank? }
  accepts_nested_attributes_for :question_images, allow_destroy: true, reject_if: proc { |attributes| attributes['image'].blank? }
  accepts_nested_attributes_for :question_topics, allow_destroy: true, reject_if: proc { |attributes| attributes['topic_id'].blank? }

  enum question_type: { mcq: 'mcq', text: 'text' }, _default: 'text'

  validates :number, presence: true, uniqueness: { scope: :exam_id }

  store_accessor :metadata, :topics_label
end
