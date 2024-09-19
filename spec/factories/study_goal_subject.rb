FactoryBot.define do
  factory :study_goal_subject do
    transient do
      curriculum { create(:curriculum) }
      study_goal { create(:study_goal) }
      subject { create(:subject, curriculum: curriculum) }
    end
    study_goal_id { study_goal.id }
    subject_id { subject.id }
  end
end
