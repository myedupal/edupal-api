require 'rails_helper'

RSpec.describe ProcessCallbackJob, type: :job do
  describe '#perform' do
    let(:stripe_subscription) { StripeMock.mock_webhook_event('customer.subscription.created') }
    let(:stripe_subscription_id) { stripe_subscription['data']['object']['id'] }
    let(:subscription) { create(:subscription, stripe_subscription_id: stripe_subscription_id) }
    let(:callback_log) { create(:callback_log, request_body: stripe_subscription) }

    before do
      allow(Subscription).to receive(:find_by!).and_return(subscription)
      allow(Stripe::Subscription).to receive(:retrieve).and_return(stripe_subscription['data']['object'])
      allow(subscription).to receive(:update!)
    end

    it 'updates subscription' do
      described_class.new.perform(callback_log.id)
      expect(subscription).to have_received(:update!).with(
        status: stripe_subscription['data']['object']['status'],
        current_period_start: Time.zone.at(stripe_subscription['data']['object']['current_period_start']),
        current_period_end: Time.zone.at(stripe_subscription['data']['object']['current_period_end'])
      )
    end
  end
end
