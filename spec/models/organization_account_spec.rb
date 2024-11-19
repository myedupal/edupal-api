require 'rails_helper'

RSpec.describe OrganizationAccount, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:organization).counter_cache(:current_headcount) }
    it { is_expected.to belong_to(:account) }
    it { is_expected.to have_one(:selecting_account).with_foreign_key(:selected_organization_id).with_primary_key(:organization_id).class_name('Account').dependent(:nullify) }
  end

  describe 'enums' do
    it do
      is_expected.to define_enum_for(:role)
                       .with_values({ admin: 'admin', trainer: 'trainer', trainee: 'trainee' })
                       .backed_by_column_of_type(:string)
    end
  end

  describe 'validations' do
    describe 'account_id_not_changed' do
      let(:organization) { create(:organization) }
      let(:account) { create(:admin) }
      let(:organization_account) { build(:organization_account, account: account, role: :admin) }

      context 'when record is persisted' do
        before { organization_account.save! }

        it 'does not allow changing account_id' do
          organization_account.account_id = create(:admin).id
          expect(organization_account).not_to be_valid
        end
      end

      context 'when record is not persisted' do
        it 'allows changing account_id' do
          organization_account.account_id = create(:admin).id
          expect(organization_account).to be_valid
        end
      end
    end
  end

  describe 'callbacks' do
    describe '#fix_owner_role_as_admin' do
      let(:owner) { create(:admin) }
      let(:organization) { create(:organization, owner: owner) }

      context 'when account is the organization owner' do
        let(:account) { owner }
        let(:organization_account) { organization.organization_accounts.find_or_create_by(account: account, role: :admin) }

        it 'sets the role to admin ' do
          organization_account.update(role: :trainer)

          expect(organization_account.admin?).to be_truthy
        end
      end

      context 'when account is not the organization owner' do
        let(:account) { create(:admin) }
        let(:organization_account) { create(:organization_account, organization: organization, account: account, role: :trainer) }

        it 'sets the role to admin ' do
          organization_account.update(account: create(:admin))

          expect(organization_account.admin?).to be_falsey
        end
      end
    end

    describe '#cannot_delete_org_owner' do
      let(:owner) { create(:admin) }
      let(:organization) { create(:organization, owner: owner) }
      let(:organization_account) { organization.organization_accounts.find_or_create_by(account: account, role: :admin) }

      context 'when account is the organization owner' do
        let(:account) { owner }

        it 'adds an error' do
          organization_account.destroy

          expect(organization_account.errors[:base]).to include('Cannot delete organization owner')
          expect(organization_account).to be_persisted
        end
      end

      context 'when account is not the organization owner' do
        let(:account) { create(:admin) }

        it 'deletes account' do
          organization_account.destroy

          expect(organization_account).to be_destroyed
        end
      end
    end
  end
end
