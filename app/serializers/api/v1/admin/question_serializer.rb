class Api::V1::Admin::QuestionSerializer < ActiveModel::Serializer
  attributes :id, :number, :question_type, :topics_label, :text, :exam_id
  attributes :created_at, :updated_at
  has_one :exam
  has_many :answers
  has_many :question_images
  has_many :question_topics
  has_many :topics
end
