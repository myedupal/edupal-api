class Api::V1::User::UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :active, :email, :points, :phone_number,
             :oauth2_provider, :oauth2_sub, :oauth2_iss, :oauth2_aud, :oauth2_profile_picture_url,
             :daily_streak, :maximum_streak, :selected_curriculum_id, :guess_word_daily_streak
  attributes :selected_organization_id
  attributes :nanoid, :referred_by_id, :referred_count, :referred_credit
  attributes :created_at, :updated_at

  has_one :stripe_profile
  has_one :selected_curriculum

  has_many :organizations
  has_one :selected_organization

  has_one :current_study_goal, serializer: Api::V1::User::StudyGoalSerializer do
    object.study_goals.current
  end
end
