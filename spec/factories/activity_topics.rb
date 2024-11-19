FactoryBot.define do
  factory :activity_topic do
    transient do
      user { create(:user) }
      activity { create(:activity, :topical, user: user, organization: organization) }
      topic { create(:topic, subject: activity.subject, organization: organization) }
      organization { nil }
    end
    activity_id { activity.id }
    topic_id { topic.id }
  end
end
