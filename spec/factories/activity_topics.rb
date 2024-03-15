FactoryBot.define do
  factory :activity_topic do
    transient do
      user { create(:user) }
      activity { create(:activity, :topical, user: user) }
      topic { create(:topic, subject: activity.subject) }
    end
    activity_id { activity.id }
    topic_id { topic.id }
  end
end
