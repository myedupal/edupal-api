require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
    it { is_expected.to have_many(:point_activities).dependent(:destroy) }
    it { is_expected.to belong_to(:selected_organization).class_name('Organization').optional }
    it { is_expected.to have_many(:owned_organizations).class_name('Organization') }
    it { is_expected.to have_many(:organization_accounts) }
    it { is_expected.to have_many(:organizations).class_name('Organization').through(:organization_accounts).source(:organization) }
  end

  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:oauth2_provider).in_array(%w[google]).allow_nil }

    context 'when oauth2_provider is present' do
      subject { described_class.new(oauth2_provider: 'google') }

      it { is_expected.to validate_presence_of(:oauth2_sub) }
    end

    context 'when oauth2_provider is not present' do
      subject { described_class.new(oauth2_provider: nil) }

      it { is_expected.not_to validate_presence_of(:oauth2_sub) }
    end

    describe 'member_of_selected_organization?' do
      subject(:account) { create(:admin) }
      let(:organization) { create(:organization) }

      context 'when not a member' do
        it 'cannot select organization' do
          account.assign_attributes(selected_organization: organization)
          expect(account).to_not be_valid
          expect(account.errors[:selected_organization]).to include(/must be a member/)
        end
      end

      context 'when is a member' do
        before { create(:organization_account, account: account, organization: organization) }

        it 'allow selecting organization' do
          account.assign_attributes(selected_organization: organization)
          expect(account).to be_valid
        end
      end
    end
  end

  describe 'methods' do
    describe '#active_for_authentication?' do
      it 'returns true if account is active' do
        account = described_class.new(active: true)

        expect(account.active_for_authentication?).to eq(true)
      end

      it 'returns false if account is not active' do
        account = described_class.new(active: false)

        expect(account.active_for_authentication?).to eq(false)
      end
    end

    describe '#oauth_authenticatable?' do
      it 'returns true if oauth2_provider is present and matches the provider' do
        account = described_class.new(oauth2_provider: 'google')

        expect(account).to be_oauth_authenticatable('google')
      end

      it 'returns false if oauth2_provider is not present' do
        account = described_class.new(oauth2_provider: nil)

        expect(account).not_to be_oauth_authenticatable('google')
      end

      it 'returns false if oauth2_provider does not match the provider' do
        account = described_class.new(oauth2_provider: 'facebook')

        expect(account).not_to be_oauth_authenticatable('google')
      end
    end

    describe '#user_registered_by_message' do
      it 'returns a message if oauth2_provider is present' do
        account = described_class.new(oauth2_provider: 'google')

        expect(account.user_registered_by_message).to eq('User was registered by google. Please login with google to continue.')
      end

      it 'returns a message if oauth2_provider is not present' do
        account = described_class.new(oauth2_provider: nil)

        expect(account.user_registered_by_message).to eq('User was registered by email. Please login with email and password to continue.')
      end
    end

    describe '#zklogin_salt' do
      before do
        allow(ZkloginSaltGenerator).to receive(:new).and_return(double(generate: 'salt'))
      end

      it 'returns nil if oauth2_sub is blank' do
        account = described_class.new(oauth2_sub: nil)

        expect(account.zklogin_salt).to be_nil
      end

      it 'returns a generated salt if oauth2_sub is present' do
        account = described_class.new(oauth2_sub: '123')

        expect(account.zklogin_salt).to eq('salt')
      end
    end
  end

  describe 'nanoid' do
    it 'generates a nanoid on create' do
      user_exam = create(:user_exam)
      expect(user_exam.nanoid).to be_present
    end
  end
end
