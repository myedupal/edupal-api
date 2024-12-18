FactoryBot.define do
  factory :submission do
    transient do
      user { create(:user) }
      challenge { create(:challenge, :daily, start_at: 1.hour.ago, end_at: 1.hour.from_now, organization: organization) }
    end
    organization { nil }
    user_id { user&.id }
    challenge_id { challenge&.id }
    title { challenge.blank? ? Faker::Lorem.sentence : nil }
    mcq_type { challenge.blank? && user_exam.blank? ? Submission.mcq_types.keys.sample : nil}
    # score { '' }
    # total_score { '' }
    # completion_seconds { '' }
    # penalty_seconds { '' }

    trait :submitted do
      after(:create) do |submission|
        submission.submit!
      end
    end

    trait :with_submission_answers do
      after(:create) do |submission|
        create_list(:submission_answer, 2, :correct_answer, challenge: submission.challenge, submission: submission, user: submission.user)
      end
    end

    trait :with_incorrect_submission_answers do
      after(:create) do |submission|
        create(:submission_answer, :correct_answer, challenge: submission.challenge, submission: submission)
        create(:submission_answer, :incorrect_answer, challenge: submission.challenge, submission: submission)
      end
    end
  end
end
