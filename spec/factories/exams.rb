FactoryBot.define do
  factory :exam do
    transient do
      paper { create(:paper) }
    end
    paper_id { paper.id }
    year { Faker::Number.between(from: 2010, to: 2020) }
    season { %w[Summer Winter].sample }
    zone { Faker::Number.between(from: 1, to: 3) }
    # level { '' }
  end
end
