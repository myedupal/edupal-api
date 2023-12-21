FactoryBot.define do
  factory :paper do
    transient do
      subject { create(:subject) }
    end
    sequence(:name) { |n| "#{Faker::Lorem.word}-#{n}" }
    subject_id { subject.id }
  end
end
