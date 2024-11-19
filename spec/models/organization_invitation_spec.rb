require 'rails_helper'

RSpec.describe OrganizationInvitation, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:account).optional(true) }
    it { is_expected.to belong_to(:created_by).optional(true).class_name('Admin') }
  end

  describe 'enums' do
    it do
      is_expected.to define_enum_for(:role)
                       .with_values({ admin: 'admin', trainer: 'trainer', trainee: 'trainee' })
                       .backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:invite_type)
                       .with_values({ group_invite: 'group_invite', user_invite: 'user_invite' })
                       .backed_by_column_of_type(:string)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:used_count).is_greater_than_or_equal_to(0).only_integer }
    it { is_expected.to validate_numericality_of(:max_uses).is_greater_than_or_equal_to(0).only_integer }

    context 'user invite' do
      context '#either_email_or_account' do
        subject(:organization_invitation) { build(:organization_invitation, invite_type: :user_invite, account: account, email: email) }

        context 'with account' do
          let(:account) { build(:user) }
          let(:email) { nil }

          it { is_expected.to be_valid }
        end

        context 'with email' do
          let(:account) { nil }
          let(:email) { Faker::Internet.email }

          it { is_expected.to be_valid }
        end

        context 'with empty email and account' do
          let(:account) { nil }
          let(:email) { nil }

          it { is_expected.to be_invalid }
        end

        context 'with email and account' do
          let(:account) { build(:user) }
          let(:email) { Faker::Internet.email }

          it { is_expected.to be_invalid }
        end
      end
    end

    context 'group invite' do
      subject(:organization_invitation) { create(:organization_invitation, invite_type: :group_invite) }
      it { is_expected.to validate_absence_of(:account) }
      it { is_expected.to validate_absence_of(:email) }
    end

    context 'invite_type_not_changed' do
      subject(:organization_invitation) { create(:organization_invitation, invite_type: :group_invite) }

      it 'does not allow changing type' do
        expect { organization_invitation.update!(invite_type: :user_invite) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe 'methods' do
    describe '#accept_invitation!' do
      let(:organization) { create(:organization, status: :active) }
      let(:organization_invitation) { create(:organization_invitation, organization: organization) }
      let(:user) { create(:user) }

      before { allow(ActiveRecord::Base).to receive(:transaction).and_yield }

      context 'when invite type is user invite' do
        context 'when invite is for user' do
          let(:organization_invitation) { create(:organization_invitation, :user_invite, organization: organization, account: user) }

          it 'adds user to organization' do
            expect(organization_invitation.accept_invitation!(user)).to be_truthy
            user.reload
            expect(user.organizations).to include(organization)
          end
        end

        context 'when invite is for another user' do
          let(:organization_invitation) { create(:organization_invitation, :user_invite, organization: organization, account: create(:user)) }

          it 'does not add user to organization' do
            expect(organization_invitation.accept_invitation!(user)).to be_falsey
            expect(organization_invitation.errors.details[:base]).to include(error: :not_for_current_user)
            user.reload
            expect(user.organizations).to_not include(organization)
          end
        end

        context 'when invite is for email' do
          let(:organization_invitation) { create(:organization_invitation, :user_invite, organization: organization, email: user.email.upcase) }

          it 'adds user to organization' do
            expect(organization_invitation.accept_invitation!(user)).to be_truthy
          end
        end

        context 'when invite is for another email' do
          let(:organization_invitation) { create(:organization_invitation, :user_invite, organization: organization, email: Faker::Internet.email) }

          it 'does not add user to organization' do
            expect(organization_invitation.accept_invitation!(user)).to be_falsey
            expect(organization_invitation.errors.details[:base]).to include(error: :not_for_current_mail)
          end
        end
      end

      context 'when invite type is group invite' do
        let(:organization_invitation) { create(:organization_invitation, :group_invite, organization: organization, used_count: 3, max_uses: 10) }

        context 'when organization is inactive' do
          let(:organization) { create(:organization, status: :inactive) }

          it 'does not add user to organization' do
            expect(organization_invitation.accept_invitation!(user)).to be_falsey
            expect(organization_invitation.errors.details[:base]).to include(error: :organization_inactive)
            user.reload
            expect(user.organizations).to_not include(organization)
          end
        end

        context 'when user is already in organization' do
          before { create(:organization_account, account: user, organization: organization) }

          it 'does not add user to organization' do
            expect(organization_invitation.accept_invitation!(user)).to be_falsey
            expect(organization_invitation.errors.details[:base]).to include(error: :user_already_joined)
          end
        end

        context 'when organization is full' do
          before do
            organization.update(current_headcount: 5, maximum_headcount: 5)
            organization_invitation.organization = organization
          end

          it 'does not add user to organization' do
            expect(organization_invitation.accept_invitation!(user)).to be_falsey
            expect(organization_invitation.errors.details[:base]).to include(error: :organization_full)
            user.reload
            expect(user.organizations).to_not include(organization)
            organization_invitation.reload
            expect(organization_invitation.used_count).to eq(3)
          end
        end

        context 'when organization is not full' do
          before do
            organization.update(current_headcount: 5, maximum_headcount: 5)
            organization_invitation.organization = organization
          end

          it 'does not add user to organization' do
            expect(organization_invitation.reload.accept_invitation!(user)).to be_truthy
          end
        end

        context 'when invite is fully used' do
          let(:organization_invitation) { create(:organization_invitation, organization: organization, used_count: 5, max_uses: 5) }

          it 'does not add user to organization' do
            expect(organization_invitation.accept_invitation!(user)).to be_falsey
            expect(organization_invitation.errors.details[:base]).to include(error: :invite_used)
            user.reload
            expect(user.organizations).to_not include(organization)
          end
        end

        context 'when invite is not fully used' do
          let(:organization_invitation) { create(:organization_invitation, organization: organization, used_count: 4, max_uses: 5) }

          it 'does not add user to organization' do
            expect(organization_invitation.accept_invitation!(user)).to be_truthy
          end
        end

        it 'adds user to organization' do
          expect(organization_invitation.accept_invitation!(user)).to be_truthy
          user.reload
          expect(user.organizations).to include(organization)
          organization_invitation.reload
          expect(organization_invitation.used_count).to eq(4)
        end

        context 'when update all returns 0' do
          before do
            # allow(OrganizationInvitation).to receive(:joins, :where, :where, :where, :update_all).and_return(0)
            query_double = double('OrganizationInvitationQuery')
            allow(query_double).to receive(:update_all) { 0 }
            # allow(query_double).to receive_messages(anything: query_double)
            allow(query_double).to receive(:method_missing) { |*_| query_double }
            allow(OrganizationInvitation).to receive(:joins) { query_double }

            allow(organization_invitation.organization).to receive(:current_headcount).and_return(0, 5)
            allow(organization_invitation.organization).to receive(:current_headcount).and_return(0, 5)
          end

          it 'returns error' do
            expect(organization_invitation.accept_invitation!(user)).to be_falsey
            expect(organization_invitation.errors.details[:base]).to include(error: :invite_update_error)
            user.reload
            expect(user.organizations).to_not include(organization)
          end
        end
      end

    end

    describe '#reject_invitation!' do
      let(:organization) { create(:organization, status: :active) }
      let(:organization_invitation) { create(:organization_invitation, :user_invite, organization: organization, account: user) }
      let(:user) { create(:user) }

      before { allow(ActiveRecord::Base).to receive(:transaction).and_yield }

      context 'with group invite' do
        let(:organization_invitation) { create(:organization_invitation, :group_invite, organization: organization) }

        it 'cannot reject group invite' do
          expect(organization_invitation.reject_invitation!(user)).to be_falsey
        end
      end

      it 'reject user invite' do
        expect(organization_invitation.reject_invitation!(user)).to be_truthy
        organization_invitation.reload
        expect(organization_invitation.max_uses).to eq(0)
      end
    end
  end

  describe 'callbacks' do
    describe '#fix_max_uses' do
      context 'when group invite' do
        let(:organization_invitation) { build(:organization_invitation, invite_type: :group_invite, max_uses: 10) }

        it 'does not fix max uses to 1' do
          expect { organization_invitation.valid? }.not_to change(organization_invitation, :max_uses).from(10)
        end
      end

      context 'when user invite' do
        let(:organization_invitation) { build(:organization_invitation, :user_invite, max_uses: 10) }

        it 'fix max uses to 1' do
          expect { organization_invitation.valid? }.to change(organization_invitation, :max_uses).to(1)
        end

        context 'with 0 max use' do
          let(:organization_invitation) { build(:organization_invitation, :user_invite, max_uses: 0) }

          it 'does not fix max uses to 1' do
            expect { organization_invitation.valid? }.to_not change(organization_invitation, :max_uses).from(0)
          end
        end
      end
    end

    describe '#downcase_email' do
      let(:organization_invitation) { build(:organization_invitation, :user_invite, email: "USER@EXAMPLE.COM") }

      it 'downcase email' do
        expect { organization_invitation.valid? }.to change(organization_invitation, :email).to('user@example.com')
      end
    end

    describe '#set_label' do
      let(:organization_invitation) { build(:organization_invitation, :group_invite, max_uses: 10, label: label) }

      context 'when label is blank' do
        let(:label) { nil }

        it 'set label' do
          expect { organization_invitation.valid? }.to change(organization_invitation, :label).from(nil).to('Group Invitation (10)')
        end
      end

      context 'when label is present' do
        let(:label) { 'invite for class 1-A' }

        it 'set label' do
          expect { organization_invitation.valid? }.not_to change(organization_invitation, :label).from('invite for class 1-A')
        end
      end
    end

    describe '#set_invitation_code' do
      let(:organization_invitation) { build(:organization_invitation, :group_invite, max_uses: 10, invitation_code: nil) }

      it 'set invitation code' do
        expect { organization_invitation.save }.to change(organization_invitation, :invitation_code).from(nil)
      end

      context 'with existing code' do
        let(:organization_invitation) { build(:organization_invitation, :group_invite, max_uses: 10, invitation_code: '123') }

        it 'does not invitation code' do
          expect { organization_invitation.save }.not_to change(organization_invitation, :invitation_code).from('123')
        end
      end
    end
  end

  describe 'scopes' do
    describe '.query_label' do
      let!(:organization_invitation) { create(:organization_invitation, label: 'classroom A-2') }
      before { create(:organization_invitation, label: 'classroom A-1') }

      it 'finds by invitation code' do
        expect(described_class.query_label('A-2')).to contain_exactly(organization_invitation)
      end
    end

    describe '.query_code' do
      let!(:organization_invitation) { create(:organization_invitation, invitation_code: '1234567890') }
      let!(:another_organization_invitation) { create(:organization_invitation, invitation_code: '23456') }

      it 'finds by invitation code' do
        expect(described_class.query_code('23456')).to contain_exactly(organization_invitation, another_organization_invitation)
      end
    end

    describe '.find_code' do
      let!(:organization_invitation) { create(:organization_invitation, invitation_code: '2345') }
      before { create(:organization_invitation, invitation_code: '123456') }

      it 'finds by invitation code' do
        expect(described_class.find_code('2345')).to contain_exactly(organization_invitation)
      end
    end

    describe '.invitation_for_user' do
      let(:email) { Faker::Internet.email }
      let(:user) { create(:user, email: email) }

      context 'with account' do
        let(:organization_invitation) { create(:organization_invitation, :user_invite, email: nil, account: user) }
        before { create(:organization_invitation, :user_invite, email: nil, account: create(:user)) }

        it 'finds for user' do
          expect(described_class.invitation_for_user(user)).to contain_exactly(organization_invitation)
        end
      end

      context 'with email' do
        let(:organization_invitation) { create(:organization_invitation, :user_invite, email: email, account: nil) }
        before { create(:organization_invitation, :user_invite, email: Faker::Internet.email, account: nil) }

        it 'finds for user' do
          expect(described_class.invitation_for_user(user)).to contain_exactly(organization_invitation)
        end
      end
    end

    describe '.active' do
      let!(:organization_invitation) { create(:organization_invitation, used_count: 1, max_uses: 10) }
      before { create(:organization_invitation, used_count: 10, max_uses: 10) }

      it 'finds by invitation code' do
        expect(described_class.active).to contain_exactly(organization_invitation)
      end
    end

    describe '.expired' do
      let!(:organization_invitation) { create(:organization_invitation, used_count: 10, max_uses: 10) }
      before { create(:organization_invitation, used_count: 9, max_uses: 10) }

      it 'finds by invitation code' do
        expect(described_class.expired).to contain_exactly(organization_invitation)
      end
    end
  end

end
