FactoryBot.define do
  factory :challenge do
    transient do
      subject { create(:subject) }
    end
    challenge_type { Challenge.challenge_types.keys.sample }
    reward_type { Challenge.reward_types.keys.sample }
    sequence(:start_at) { |n| n.days.from_now }
    end_at { start_at + 1.hour }
    subject_id { subject.id }
    reward_points { rand(10..50) }
    penalty_seconds { rand(30..180) }
  end
end
