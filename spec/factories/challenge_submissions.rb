FactoryBot.define do
  factory :challenge_submission do
    transient do
      user { create(:user) }
      challenge { create(:challenge) }
    end
    user_id { user.id }
    challenge_id { challenge.id }
    # score { '' }
    # total_score { '' }
    # completion_seconds { '' }
    # penalty_seconds { '' }
  end
end
