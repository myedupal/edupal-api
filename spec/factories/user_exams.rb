FactoryBot.define do
  factory :user_exam do
    transient do
      created_by { create(:user) }
      subject { create(:subject) }
    end
    title { Faker::Lorem.sentence }
    created_by_id { created_by.id }
    subject_id { subject.id }
    is_public { false }

    trait :with_questions do
      after(:create) do |user_exam|
        create_list(:user_exam_question, 5, user_exam: user_exam)
      end
    end
  end
end
