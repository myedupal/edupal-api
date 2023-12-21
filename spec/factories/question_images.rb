FactoryBot.define do
  factory :question_image do
    transient do
      question { create(:question) }
    end
    question_id { question.id }
    image { "data:image/png;base64,(#{Base64.encode64(Rails.root.join('spec/fixtures/product.png').read)})" }
    display_order { Faker::Number.between(from: 1, to: 10) }
  end
end
