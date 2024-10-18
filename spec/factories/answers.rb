FactoryBot.define do
  factory :answer do
    transient do
      question { create(:question) }
    end
    question_id { question.id }
    text { Faker::Lorem.sentence }
    image { "data:image/png;base64,(#{Base64.encode64(Rails.root.join('spec/fixtures/product.png').read)})" }
    is_correct { true }

    trait :incorrect do
      is_correct { false }
    end

  end
end
