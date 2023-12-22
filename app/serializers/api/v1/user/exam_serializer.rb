class Api::V1::User::ExamSerializer < ActiveModel::Serializer
  attributes :id, :year, :season, :zone, :level, :file, :marking_scheme, :paper_id
  has_one :paper
end
