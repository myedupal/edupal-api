class Api::V1::User::QuestionSerializer < ActiveModel::Serializer
  attributes :id, :number, :question_type, :text, :exam_id, :subject_id, :activity_question_presence
  has_one :exam
  has_one :subject
  has_many :answers
  has_many :question_images
  has_many :question_topics
  has_many :topics

  def activity_question_presence
    return false unless object.respond_to?(:activity_question_presence)

    object.activity_question_presence
  end
end
