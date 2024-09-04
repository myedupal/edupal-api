FactoryBot.define do
  factory :guess_word_question do
    guess_word_pool { create(:guess_word_pool) }
    word { Faker::Lorem.words.join }
    description { Faker::Lorem.sentence }
  end
end
