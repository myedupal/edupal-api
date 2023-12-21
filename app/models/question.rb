class Question < ApplicationRecord
  belongs_to :exam

  has_many :answers, dependent: :destroy
  has_many :question_images, dependent: :destroy
  has_many :question_topics, dependent: :destroy
  has_many :topics, -> { distinct }, through: :question_topics

  accepts_nested_attributes_for :answers, allow_destroy: true, reject_if: proc { |attributes| attributes['text'].blank? && attributes['image'].blank? }
  accepts_nested_attributes_for :question_images, allow_destroy: true, reject_if: proc { |attributes| attributes['image'].blank? }
  accepts_nested_attributes_for :question_topics, allow_destroy: true, reject_if: proc { |attributes| attributes['topic_id'].blank? }

  enum question_type: { mcq: 'mcq', text: 'text' }, _default: 'text'

  validates :number, presence: true

  store_accessor :metadata, :topics_label
end
