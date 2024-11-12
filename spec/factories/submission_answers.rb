FactoryBot.define do
  factory :submission_answer do
    transient do
      user { create(:user) }
      challenge { create(:challenge, organization: organization) }
      question { create(:question, :mcq_with_answer, organization: organization) }
      submission { create(:submission, user: user, challenge: challenge, organization: organization) }
      skip_challenge_question { false }
    end
    organization { nil }
    submission_id { submission&.id }
    question_id { question&.id }
    user_id { user&.id }
    answer { %w[A B C D].sample }
    recorded_time { rand(5..45).minutes.seconds.to_i }

    after(:build) do |submission_answer, evaluator|
      if submission_answer.submission&.challenge && !evaluator.skip_challenge_question
        ChallengeQuestion.find_or_create_by!(
          challenge_id: submission_answer.submission.challenge_id,
          question_id: submission_answer.question_id
        ) do |challenge_question|
          attributes = attributes_for(:challenge_question)
          challenge_question.score = attributes[:score]
          challenge_question.display_order = attributes[:display_order]
        end
      end
    end

    trait :correct_answer do
      answer { question.answers.correct.first.text }
    end

    trait :incorrect_answer do
      answer { 'X' }
    end
  end
end
