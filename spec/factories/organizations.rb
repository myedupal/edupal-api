FactoryBot.define do
  factory :organization do
    transient do
      owner { create(:admin) }
    end
    owner_id { owner&.id }
    title { Faker::Lorem.words(number: 3).join(' ') }
    description { Faker::Lorem.paragraph }
    status { :active }
    maximum_headcount { 15 }
  end
end
