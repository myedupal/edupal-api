class Api::V1::Admin::GuessWordPoolSerializer < ActiveModel::Serializer
  attributes :id, :organization_id, :default_pool, :subject_id, :user_id
  attributes :title, :description, :published, :guess_word_questions_count

  has_many :guess_word_questions, unless: -> { instance_options[:skip_questions] }
end
