FactoryBot.define do
  factory :submission_answer do
    transient do
      challenge_submission { create(:challenge_submission) }
      question { create(:question, :mcq_with_answer) }
      user { create(:user) }
    end
    challenge_submission_id { challenge_submission&.id }
    question_id { question.id }
    user_id { user.id }
    answer { %w[A B C D].sample }
  end
end
