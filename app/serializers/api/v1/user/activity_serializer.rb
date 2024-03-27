class Api::V1::User::ActivitySerializer < ActiveModel::Serializer
  attributes :id, :activity_type, :activity_questions_count, :user_id,
             :subject_id, :exam_id, :metadata, :topic_ids, :paper_ids,
             :questions_count, :title, :recorded_time
  attributes :created_at, :updated_at
  # has_one :user
  has_one :subject
  has_one :exam
  has_many :papers
  has_many :topics

  def topic_ids
    object.topics.pluck(:id)
  end

  def paper_ids
    object.papers.pluck(:id)
  end
end
