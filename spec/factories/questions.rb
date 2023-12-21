FactoryBot.define do
  factory :question do
    transient do
      exam { create(:exam) }
    end
    exam_id { exam.id }
    number { Faker::Number.between(from: 1, to: 100) }
    question_type { Question.question_types.keys.sample }
    # metadata { '' }
  end
end
