FactoryBot.define do
  factory :exam do
    transient do
      subject { create(:subject, organization: organization) }
      paper { create(:paper, subject: subject, organization: organization) }
    end
    organization { nil }
    paper_id { paper.id }
    sequence(:year) { |n| 2020 + n }
    season { %w[Summer Winter].sample }
    zone { Faker::Number.between(from: 1, to: 3) }
    # level { '' }
  end
end
