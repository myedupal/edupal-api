require 'rails_helper'

RSpec.describe Api::V1::User::StudyGoalPolicy, type: :policy do
  let(:user) { create(:user) }

  subject { described_class }

  describe ".scope" do
    let(:scope) { StudyGoal.all }
    let(:organization) { create(:organization) }

    let!(:study_goal) { create(:study_goal, user: user) }
    let!(:another_study_goal) { create(:study_goal, user: create(:user)) }
    let!(:organization_study_goal) { create(:study_goal, user: user, organization: organization) }
    let!(:another_organization_study_goal) { create(:study_goal, user: create(:user), organization: organization) }

    context "when not selected an organization" do
      it "returns users study goals" do
        expect(subject::Scope.new(user, scope).resolve).to contain_exactly(study_goal)
      end
    end

    context "when selected an organization" do
      let(:selected_organization) { organization }
      before { create(:organization_account, account: user, organization: organization) }
      before { user.update(selected_organization: organization) }

      it "returns users study goals" do
        expect(subject::Scope.new(user, scope).resolve).to contain_exactly(organization_study_goal)
      end
    end
  end
end
