FactoryBot.define do
  factory :subject do
    transient do
      curriculum { create(:curriculum) }
    end
    sequence(:name) { |n| "#{Faker::Lorem.word}-#{n}" }
    curriculum_id { curriculum.id }
    code { SecureRandom.alphanumeric(5).upcase }
    is_published { true }
    banner { "data:image/png;base64,(#{Base64.encode64(Rails.root.join('spec/fixtures/product.png').read)})" }
  end
end
