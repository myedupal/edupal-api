class Api::V1::Web::PaperSerializer < ActiveModel::Serializer
  attributes :id, :name, :subject_id
  has_one :subject
  has_many :exams
end
