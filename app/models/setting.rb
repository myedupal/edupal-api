# RailsSettings Model
class Setting < RailsSettings::Base
  cache_prefix { "v1" }

  field :daily_challenge_points, type: :integer, default: 10
  field :answered_question_points, type: :integer, default: 5
end
