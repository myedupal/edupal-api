FactoryBot.define do
  factory :guess_word_submission do
    guess_word_id { create(:guess_word).id }
    user_id { create(:user).id }

    # completed_at { Faker::Time.between(from: Time.zone.now - 30.days, to: Time.zone.now) }

    transient do
      guess_count { Faker::Number.between(from: 1, to: 4) }
    end

    trait :success do
      status { :success }
      completed_at { Faker::Time.between(from: Time.zone.now - 30.days, to: Time.zone.now) }
    end

    trait :expired do
      status { :expired }
      completed_at { Faker::Time.between(from: Time.zone.now - 30.days, to: Time.zone.now) }
    end

    trait :failed do
      status { :failed }
      completed_at { Faker::Time.between(from: Time.zone.now - 30.days, to: Time.zone.now) }
    end

    trait :with_guesses do
      after(:create) do |guess_word_submission, evaluator|
        create_list(:guess_word_submission_guess, evaluator.guess_count, guess_word_submission: guess_word_submission)
      end
    end
  end
end
