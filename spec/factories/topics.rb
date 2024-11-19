FactoryBot.define do
  factory :topic do
    transient do
      subject { create(:subject, organization: organization) }
    end
    organization { nil }
    sequence(:name) { |n| "#{Faker::Lorem.word}-#{n}" }
    sequence(:display_order) { |n| n }
    subject_id { subject.id }
  end
end
