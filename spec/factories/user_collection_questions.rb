FactoryBot.define do
  factory :user_collection_question do
    transient do
      user_collection { create(:user_collection) }
      curriculum { user_collection.curriculum }
      subject { create(:subject, curriculum: curriculum) }
      question { create(:question, subject: subject) }
    end
    question_id { question.id }
    user_collection_id { user_collection.id }
  end
end
