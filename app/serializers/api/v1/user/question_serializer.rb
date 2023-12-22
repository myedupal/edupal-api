class Api::V1::User::QuestionSerializer < ActiveModel::Serializer
  attributes :id, :number, :question_type, :text
  has_one :exam
  has_many :answers
  has_many :question_images
  has_many :question_topics
  has_many :topics
end
