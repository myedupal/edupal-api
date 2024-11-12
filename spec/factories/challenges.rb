FactoryBot.define do
  factory :challenge do
    transient do
      subject { create(:subject, organization: organization) }
    end
    organization { nil }
    challenge_type { Challenge.challenge_types.keys.sample }
    reward_type { Challenge.reward_types.keys.sample }
    sequence(:start_at) { |n| n.days.from_now }
    end_at { start_at + 2.hours }
    subject_id { subject&.id }
    reward_points { rand(10..50) }
    penalty_seconds { rand(30..180) }
    banner { "data:image/png;base64,(#{Base64.encode64(Rails.root.join('spec/fixtures/product.png').read)})" }

    trait :published do
      is_published { true }
    end

    trait :daily do
      challenge_type { :daily }
    end

    trait :with_questions do
      after(:create) do |challenge|
        create_list(:challenge_question, 3, challenge: challenge)
      end
    end

    trait :custom do
      challenge_type { :custom }
      start_at { Time.zone.now }
      end_at { nil }
    end
  end
end
