FactoryBot.define do
  factory :curriculum do
    sequence(:name) { |n| "#{Faker::Lorem.word}-#{n}" }
    board { %w[Cambridge IB Malaysia Edexcel AQA IGCSE].sample }
    sequence(:display_order) { |n| n }
    is_published { true }
  end
end
