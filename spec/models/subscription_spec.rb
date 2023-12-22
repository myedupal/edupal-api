require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:plan) }
    it { is_expected.to belong_to(:price) }
    it { is_expected.to belong_to(:created_by) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:start_at) }
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
