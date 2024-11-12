FactoryBot.define do
  factory :question_topic do
    transient do
      question { create(:question, organization: organization) }
      topic { create(:topic, organization: organization) }
      organization { nil }
    end
    question_id { question.id }
    topic_id { topic.id }
  end
end
