FactoryBot.define do
  factory :subject do
    transient do
      curriculum { create(:curriculum) }
    end
    sequence(:name) { |n| "#{Faker::Lorem.word}-#{n}" }
    curriculum_id { curriculum.id }
    code { SecureRandom.alphanumeric(5).upcase }
    is_published { true }
  end
end
