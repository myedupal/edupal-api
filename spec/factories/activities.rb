FactoryBot.define do
  factory :activity do
    transient do
      user { create(:user) }
    end
    user_id { user.id }

    trait :yearly do
      transient do
        exam { create(:exam) }
      end
      activity_type { :yearly }
      exam_id { exam.id }
    end

    trait :topical do
      transient do
        subject { create(:subject) }
      end
      subject_id { subject.id }
      activity_type { :topical }
      exam_id { nil }
      after(:create) do |activity|
        create(:activity_paper, activity: activity)
        create(:activity_topic, activity: activity)
      end
    end
  end
end
