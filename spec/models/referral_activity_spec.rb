require 'rails_helper'

RSpec.describe ReferralActivity, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:referral_source).optional(true) }
  end

  describe 'monetize' do
    it { is_expected.to monetize(:credit_cents) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:referral_type).with_values(signup: 'Signup', subscription: 'Subscription').backed_by_column_of_type(:string) }
  end

  describe 'callbacks' do
    describe '#update_account_credits' do
      let(:user) { create(:user) }
      let(:referral_activity) { build(:referral_activity, user: user, voided: false) }

      context 'with valid referral activity' do
        it 'updates referral credit' do
          expect { referral_activity.save! }.to change { user.reload.referred_credit_cents }.from(0).to(referral_activity.credit_cents)
        end

        context 'with valid previous referral activity' do
          let!(:previous_referral_activity) { create(:referral_activity, user: user) }

          it 'updates referral credit' do
            expect { referral_activity.save! }.to change { user.reload.referred_credit_cents }.from(previous_referral_activity.credit_cents).to(referral_activity.credit_cents + previous_referral_activity.credit_cents)
          end
        end

        context 'with invalid previous referral activity' do
          let!(:previous_referral_activity) { create(:referral_activity, user: user, voided: true) }

          it 'updates referral credit' do
            expect { referral_activity.save! }.to change { user.reload.referred_credit_cents }.from(0).to(referral_activity.credit_cents)
          end
        end
      end

      context 'with invalid referral activity' do
        let(:referral_activity) { build(:referral_activity, user: user, voided: true) }

        it 'does not updates referral credit' do
          expect { referral_activity.save! }.to_not change { user.reload.referred_credit_cents }.from(0)
        end
      end
    end
  end

  describe 'methods' do
    describe '#nullify!' do
      let(:user) { create(:user) }
      let(:referral_activity) { create(:referral_activity, user: user) }

      it 'update credit' do
        expect { referral_activity.nullify! }.to change { referral_activity.reload.voided }.to(true)
        expect(user.reload.referred_credit_cents).to eq(0)
      end
    end

    describe '#revalidate!' do
      let(:user) { create(:user) }
      let(:referral_activity) { create(:referral_activity, voided: true, user: user) }

      it 'update credit' do
        expect { referral_activity.revalidate! }.to change { referral_activity.reload.voided }.to(false)
        expect(user.reload.referred_credit_cents).to eq(referral_activity.credit_cents)
      end
    end
  end
end
