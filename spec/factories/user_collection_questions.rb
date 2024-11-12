FactoryBot.define do
  factory :user_collection_question do
    transient do
      organization { nil }
      curriculum { user_collection.curriculum }
      user_collection { create(:user_collection, organization: organization) }
      subject { create(:subject, curriculum: curriculum, organization: organization) }
      question { create(:question, subject: subject, organization: organization) }
    end
    question_id { question.id }
    user_collection_id { user_collection.id }
  end
end
