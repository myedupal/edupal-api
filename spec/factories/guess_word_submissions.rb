FactoryBot.define do
  factory :guess_word_submission do
    guess_word_id { create(:guess_word).id }
    user_id { create(:user).id }

    # completed_at { Faker::Time.between(from: Time.zone.now - 30.days, to: Time.zone.now) }
  end
end
