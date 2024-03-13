FactoryBot.define do
  factory :challenge_question do
    transient do
      challenge { create(:challenge) }
      question { create(:question) }
    end
    challenge_id { challenge.id }
    question_id { question.id }
    sequence(:display_order) { |n| n }
    score { rand(5..20) }
  end
end
