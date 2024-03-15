FactoryBot.define do
  factory :question do
    transient do
      subject { create(:subject) }
      paper { create(:paper, subject: subject) }
      exam { create(:exam, paper: paper) }
    end
    subject_id { subject&.id }
    exam_id { exam&.id }
    sequence(:number)
    question_type { Question.question_types.keys.sample }
    # metadata { '' }
    #
    trait :mcq_with_answer do
      question_type { :mcq }
      after(:create) do |question|
        create(:answer, question: question, text: %w[A B C D].sample)
      end
    end

    trait :open_ended do
      question_type { :text }
    end
  end
end
