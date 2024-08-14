FactoryBot.define do
  factory :user_collection do
    transient do
      user { create(:user) }
      curriculum { create(:curriculum) }
    end
    user_id { user.id }
    curriculum_id { curriculum.id }
    collection_type { UserCollection.collection_types.keys.sample }
    title { Faker::Lorem.unique.words(number: 2).join }
    description { Faker::Lorem.paragraph }

    trait :with_questions do
      transient do
        questions_count { 3 }
      end

      after(:create) do |user_collection, evaluator|
        create_list(:user_collection_question, evaluator.questions_count, user_collection: user_collection)
      end
    end
  end
end
