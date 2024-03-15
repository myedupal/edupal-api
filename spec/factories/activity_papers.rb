FactoryBot.define do
  factory :activity_paper do
    transient do
      user { create(:user) }
      activity { create(:activity, :topical, user: user) }
      paper { create(:paper, subject: activity.subject) }
    end
    activity_id { activity.id }
    paper_id { paper.id }
  end
end
