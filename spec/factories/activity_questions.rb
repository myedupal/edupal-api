FactoryBot.define do
  factory :activity_question do
    transient do
      user { create(:user) }
      activity { create(:activity, :topical, user: user) }
      question { create(:question, subject: activity.subject) }
    end
    activity_id { activity.id }
    question_id { question.id }
  end
end
