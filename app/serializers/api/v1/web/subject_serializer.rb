class Api::V1::Web::SubjectSerializer < ActiveModel::Serializer
  include ExamFilteringHelper

  attributes :id, :name, :code, :curriculum_id
  attributes :exams_filtering
  has_one :curriculum
  has_many :papers
end
