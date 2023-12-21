FactoryBot.define do
  factory :answer do
    transient do
      question { create(:question) }
    end
    question_id { question.id }
    text { Faker::Lorem.sentence }
    image { "data:image/png;base64,(#{Base64.encode64(Rails.root.join('spec/fixtures/product.png').read)})" }
  end
end
