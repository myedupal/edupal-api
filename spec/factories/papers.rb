FactoryBot.define do
  factory :paper do
    transient do
      subject { create(:subject, organization: organization) }
    end
    organization { nil }
    sequence(:name) { |n| "#{Faker::Lorem.word}-#{n}" }
    subject_id { subject.id }
  end
end
