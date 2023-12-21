FactoryBot.define do
  factory :curriculum do
    sequence(:name) { |n| "#{Faker::Lorem.word}-#{n}" }
    board { %w[Cambridge IB Malaysia Edexcel AQA IGCSE].sample }
    display_order { Faker::Number.between(from: 1, to: 10) }
  end
end
