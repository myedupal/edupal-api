FactoryBot.define do
  factory :activity_paper do
    transient do
      user { create(:user) }
      organization { nil }
      activity { create(:activity, :topical, user: user, organization: organization) }
      paper { create(:paper, subject: activity.subject, organization: organization) }
    end
    activity_id { activity.id }
    paper_id { paper.id }
  end
end
