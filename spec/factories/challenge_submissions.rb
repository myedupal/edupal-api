FactoryBot.define do
  factory :challenge_submission do
    transient do
      user { create(:user) }
      challenge { create(:challenge, start_at: 1.hour.ago, end_at: 1.hour.from_now) }
    end
    user_id { user.id }
    challenge_id { challenge.id }
    # score { '' }
    # total_score { '' }
    # completion_seconds { '' }
    # penalty_seconds { '' }
  end
end
