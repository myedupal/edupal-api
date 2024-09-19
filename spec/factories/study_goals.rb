FactoryBot.define do
  factory :study_goal do
    transient do
      curriculum { create(:curriculum) }
    end
    user { create(:user) }
    curriculum_id { curriculum.id }
    a_grade_count { Faker::Number.between(from: 1, to: 3) }

    trait :with_subject do
      transient do
        subject_count { 3 }
      end

      after(:create) do |study_goal, evaluator|
        evaluator.subject_count.times do
          create(:study_goal_subject, study_goal: study_goal, curriculum: study_goal.curriculum)
        end
      end
    end
  end
end
