FactoryBot.define do
  factory :submission_answer do
    transient do
      user { create(:user) }
      question { create(:question, :mcq_with_answer) }
      challenge_question { create(:challenge_question, question: question) }
      challenge_submission { create(:challenge_submission, user: user, challenge: challenge_question.challenge) }
    end
    challenge_submission_id { challenge_submission&.id }
    question_id { question.id }
    user_id { user.id }
    answer { %w[A B C D].sample }
  end
end
