FactoryBot.define do
  factory :guess_word_pool do
    transient do
      subject { create(:subject, organization: organization) }
    end
    organization { nil }
    default_pool { false }
    subject_id { subject.id }
    user { nil }
    published { true }
    title { Faker::Lorem.words(number: 3).join(' ') }
    description { Faker::Lorem.sentence }

    trait :with_questions do
      transient do
        question_count { 3 }
      end
      after(:create) do |pool, evaluator|
        create_list(:guess_word_question, evaluator.question_count, guess_word_pool: pool)
      end
    end
  end
end
