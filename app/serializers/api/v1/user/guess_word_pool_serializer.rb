class Api::V1::User::GuessWordPoolSerializer < ActiveModel::Serializer
  attributes :id, :default_pool, :subject_id, :user_id
  attributes :title, :description, :published, :guess_word_questions_count

  has_many :guess_word_questions, unless: -> { instance_options[:skip_questions] }

  has_one :daily_guess_word, if: -> { instance_options[:include_daily_guess_word] }
end
