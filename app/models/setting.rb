# RailsSettings Model
class Setting < RailsSettings::Base
  cache_prefix { "v1" }

  field :daily_challenge_points, type: :integer, default: 1
  field :answered_question_points, type: :integer, default: 1
  field :daily_check_in_points, type: :integer, default: 1
  field :referral_signup_credit_cents, type: :integer, default: 0
end
