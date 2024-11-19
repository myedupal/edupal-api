FactoryBot.define do
  factory :saved_user_exam do
    transient do
      user { create(:user) }
      user_exam { create(:user_exam, organization: organization) }
    end
    organization { nil }
    user_id { user.id }
    user_exam_id { user_exam.id }
  end
end
