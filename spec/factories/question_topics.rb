FactoryBot.define do
  factory :question_topic do
    transient do
      question { create(:question) }
      topic { create(:topic) }
    end
    question_id { question.id }
    topic_id { topic.id }
  end
end
