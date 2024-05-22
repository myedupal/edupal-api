class Api::V1::Admin::SubjectSerializer < ActiveModel::Serializer
  include ExamFilteringHelper

  attributes :id, :name, :code, :curriculum_id, :is_published
  attributes :exams_filtering
  attributes :created_at, :updated_at
  has_one :curriculum
  has_many :papers
end
