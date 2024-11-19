FactoryBot.define do
  factory :activity do
    transient do
      user { create(:user) }
    end
    organization { nil }
    user_id { user.id }

    subject { create(:subject, organization: organization) }

    trait :yearly do
      transient do
        exam { create(:exam, organization: organization) }
      end
      activity_type { :yearly }
      exam_id { exam.id }
    end

    trait :topical do
      transient do
        subject { create(:subject, organization: organization) }
      end
      subject_id { subject.id }
      activity_type { :topical }
      exam_id { nil }
      after(:create) do |activity, evaluator|
        create(:activity_paper, activity: activity, organization: evaluator.organization)
        create(:activity_topic, activity: activity, organization: evaluator.organization)
      end
    end
  end
end
