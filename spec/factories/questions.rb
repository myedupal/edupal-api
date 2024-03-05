FactoryBot.define do
  factory :question do
    transient do
      subject { create(:subject) }
      exam { create(:exam, paper: create(:paper, subject: subject)) }
    end
    subject_id { subject&.id }
    exam_id { exam&.id }
    sequence(:number)
    question_type { Question.question_types.keys.sample }
    # metadata { '' }
  end
end
