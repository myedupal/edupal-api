FactoryBot.define do
  factory :guess_word do
    subject_id { create(:subject).id }
    answer { Faker::Lorem.word }
    description { Faker::Lorem.paragraph }
    attempts { Faker::Number.between(from: 6, to: 12) }
    reward_points { Faker::Number.between(from: 3, to: 10) }

    start_at { Faker::Time.between(from: Time.zone.now - 30.days, to: Time.zone.now - 1.day) }
    end_at { Faker::Time.between(from: Time.zone.now + 3.day, to: Time.zone.now + 7.days) }
  end
end
