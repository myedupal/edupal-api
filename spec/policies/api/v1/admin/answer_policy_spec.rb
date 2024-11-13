require 'rails_helper'

RSpec.describe Api::V1::Admin::AnswerPolicy, type: :policy do
  subject { described_class }
  let(:answer_without_org) { create(:question, :mcq_with_answer, organization: nil).answers.first! }
  let(:admin_without_org) { create(:admin, selected_organization: nil, super_admin: false) }

  describe ".scope" do
    let(:policy_scope) { Api::V1::Admin::AnswerPolicy::Scope.new(policy_user, Answer).resolve }
    let!(:organization) { create(:organization, title: "Test Organization") }
    let!(:answer_in_org) { create(:question, :mcq_with_answer, organization: organization).answers.first! }
    let(:answer_without_org) { create(:question, :mcq_with_answer, organization: nil).answers.first! }

    context "when user has a selected organization" do
      let(:admin_with_org) { create(:admin, :with_organization, selected_organization: organization, super_admin: false) }
      let(:policy_user) { admin_with_org }

      it "includes only records from the user's organization" do
        expect(policy_scope).to contain_exactly(answer_in_org)
      end
    end

    context "when user does not have a selected organization" do
      let(:admin_without_org) { create(:admin, selected_organization: nil, super_admin: false) }
      let(:policy_user) { admin_without_org }

      it "includes only records without an organization" do
        expect(policy_scope).to contain_exactly(answer_without_org)
      end
    end

    context 'when admin is super admin' do
      let(:policy_user) { create(:admin, selected_organization: nil, super_admin: true) }

      it "includes only records in selected organization" do
        expect(policy_scope).to contain_exactly(answer_without_org)
      end
    end
  end

  permissions :show? do
    it "allows access" do
      expect(subject).to permit(admin_without_org, answer_without_org)
    end
  end

  permissions :create? do
    it "allows access" do
      expect(subject).to permit(admin_without_org, answer_without_org)
    end
  end

  permissions :update? do
    it "allows access" do
      expect(subject).to permit(admin_without_org, answer_without_org)
    end
  end

  permissions :destroy? do
    it "allows access" do
      expect(subject).to permit(admin_without_org, answer_without_org)
    end
  end
end
