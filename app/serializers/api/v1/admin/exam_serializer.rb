class Api::V1::Admin::ExamSerializer < ActiveModel::Serializer
  attributes :id, :year, :season, :zone, :level, :file, :marking_scheme
  attributes :created_at, :updated_at
  has_one :paper
end
