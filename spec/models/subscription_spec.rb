require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:plan) }
    it { is_expected.to belong_to(:price).optional }
    it { is_expected.to belong_to(:created_by) }
    it { is_expected.to have_many(:referred_activities).class_name('ReferralActivity').dependent(:nullify) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:start_at) }
  end

  describe 'callbacks' do
    describe '#create_referral_activity' do
      let(:user) { create(:user, referred_by: referred_by) }
      let(:referred_by) { nil }
      let(:status) { 'active' }
      let(:plan) { create(:plan, referral_fee_percentage: 10) }
      let(:price) { create(:price) }
      let(:subscription) { create(:subscription, user: user, plan: plan, price: price, status: status) }

      context 'with active status' do
        context 'with referred user' do
          let!(:referred_by) { create(:user) }

          it 'creates referral activity' do
            expect { subscription }.to change(ReferralActivity, :count).by(1)
            expect(subscription.referred_activities.count).to eq(1)
            referral_activity = subscription.referred_activities.first!
            expect(referral_activity.user).to eq(referred_by)
            expect(referral_activity.referral_source).to eq(subscription)
            expect(referral_activity.referral_type).to eq('subscription')
            expect(referral_activity.credit_cents).to eq(price.amount_cents * plan.referral_fee_percentage / 100)

            expect(referred_by.reload.referred_credit_cents).to eq(price.amount_cents * plan.referral_fee_percentage / 100)
          end

          context 'with no price' do
            let(:subscription) { create(:subscription, user: user, plan: plan, status: status, price_id: nil) }

            it 'does not create referral activity' do
              expect { subscription }.not_to change(ReferralActivity, :count)
            end
          end

          context 'with existing referral activity' do
            let!(:referral_activity) { create(:referral_activity, user: referred_by, referral_source: subscription) }

            it 'does not create referral activity' do
              expect { subscription.touch }.not_to change(ReferralActivity, :count)
            end
          end

          context 'with non-active status' do
            let(:status) { 'incomplete' }

            it 'does not create referral activity' do
              expect { subscription }.not_to change(ReferralActivity, :count)
            end

            context 'when updated to active' do
              it 'creates referral activity' do
                expect { subscription.update(status: 'active') }.to change(ReferralActivity, :count).by(1)
              end
            end
          end
        end

        context 'with no referred user' do
          it 'does not create referral activity' do
            expect { subscription }.not_to change(ReferralActivity, :count)
          end
        end
      end
    end
  end

  describe 'scopes' do
    describe '.active' do
      let!(:active_subscription) { create(:subscription, :active) }
      let!(:past_subscription) { create(:subscription, :active, start_at: 1.month.ago, end_at: 1.day.ago) }
      let!(:future_subscription) { create(:subscription, :active, start_at: 1.day.from_now, end_at: 1.month.from_now) }
      let!(:incomplete_subscription) { create(:subscription, :incomplete) }
      let(:active_subscriptions) { described_class.active }

      it 'returns active subscriptions' do
        expect(active_subscriptions).to include(active_subscription)
        expect(active_subscriptions).not_to include(past_subscription)
        expect(active_subscriptions).not_to include(future_subscription)
        expect(active_subscriptions).not_to include(incomplete_subscription)
      end
    end
  end
end
