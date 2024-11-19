class Api::V1::Admin::SubjectSerializer < ActiveModel::Serializer
  include ExamFilteringHelper

  attributes :id, :organization_id, :name, :code, :curriculum_id, :is_published, :banner
  attribute :exams_filtering, unless: -> { instance_options[:skip_exams_filtering] }
  attributes :created_at, :updated_at
  has_one :curriculum
  has_many :papers
end
