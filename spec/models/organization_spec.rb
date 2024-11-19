require 'rails_helper'

RSpec.describe Organization, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:owner).class_name('Admin') }

    it { is_expected.to have_many(:organization_accounts).dependent(:destroy) }
    it { is_expected.to have_many(:accounts).through(:organization_accounts).counter_cache(:current_headcount) }
    it { is_expected.to have_many(:admins).conditions(role: :admin).class_name('Admin').through(:organization_accounts) }
    it { is_expected.to have_many(:trainer).conditions(role: :trainer).class_name('Admin').through(:organization_accounts) }
    it { is_expected.to have_many(:trainee).conditions(role: :trainee).class_name('User').through(:organization_accounts) }

    it { is_expected.to have_many(:selecting_account).with_foreign_key(:selected_organization_id).dependent(:nullify).class_name('Account') }

    it { is_expected.to have_many(:organization_invitations).dependent(:destroy) }
  end

  describe 'enums' do
    it do
      is_expected.to define_enum_for(:status)
                       .with_values({ pending: 'pending', active: 'active', inactive: 'inactive' })
                       .backed_by_column_of_type(:string)

    end
  end

  describe 'methods' do
    describe "#leave!" do
      let(:organization) { create(:organization) }
      let(:user) { create(:user) }

      context 'when user is not a member of the organization' do
        it 'adds error and returns false' do
          expect(organization.leave!(user)).to be false
          expect(organization.errors.full_messages).to include('You are not a member of this organization')
        end
      end

      context 'when admin owns the organization' do
        let(:organization) { create(:organization, owner: admin) }
        let(:admin) { create(:admin) }

        it 'does not allow owner to leave' do
          expect(organization.leave!(admin)).to be false
          expect(organization.errors.full_messages).to include('You cannot leave your own organization')
          expect(organization.organization_accounts.find_by(account: admin, role: :admin)).to be_present
        end
      end

      context 'with normal trainee' do
        before { create(:organization_account, organization: organization, account: user, role: :trainee)}

        it 'removes the user from the organization' do
          expect(organization.leave!(user)).to be true
          expect(organization.organization_accounts.find_by(account: user, role: :trainee)).to be_nil
        end
      end
    end
  end

  describe 'callbacks' do
    describe '#create_owner' do
      let(:organization) { build(:organization) }

      context 'without organization account for owner' do
        it 'will create organization account for owner' do
          expect { organization.save! }.to change(organization.organization_accounts, :count).by(1)
        end
      end
    end
  end
end
