FactoryBot.define do
  factory :user_exam_question do
    transient do
      user_exam { create(:user_exam) }
      question { create(:question, :mcq_with_answer) }
    end
    user_exam_id { user_exam.id }
    question_id { question.id }
  end
end
