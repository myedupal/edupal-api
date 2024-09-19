FactoryBot.define do
  factory :guess_word_dictionary do
    word { Faker::Lorem.unique.word }
  end
end
