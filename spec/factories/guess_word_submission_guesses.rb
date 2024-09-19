FactoryBot.define do
  factory :guess_word_submission_guess do
    guess_word_submission_id { create(:guess_word_submission).id }
    guess { Faker::Lorem.word }
    result { '' }
  end
end
