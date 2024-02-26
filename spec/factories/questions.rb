FactoryBot.define do
  factory :question do
    transient do
      exam { create(:exam) }
    end
    exam_id { exam.id }
    sequence(:number)
    question_type { Question.question_types.keys.sample }
    # metadata { '' }
  end
end
