FactoryBot.define do
  factory :submission_answer do
    transient do
      user { create(:user) }
      challenge { create(:challenge) }
      question { create(:question, :mcq_with_answer) }
      challenge_submission { create(:challenge_submission, user: user, challenge: challenge) }
    end
    challenge_submission_id { challenge_submission&.id }
    question_id { question.id }
    user_id { user.id }
    answer { %w[A B C D].sample }

    after(:build) do |_submission_answer, evaluator|
      create(:challenge_question, question: evaluator.question, challenge: evaluator.challenge)
    end

    trait :correct_answer do
      answer { question.answers.first.text }
    end

    trait :incorrect_answer do
      answer { 'X' }
    end
  end
end
