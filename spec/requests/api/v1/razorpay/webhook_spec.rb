require 'swagger_helper'

RSpec.describe 'api/v1/razorpay/webhooks', type: :request do
  path '/api/v1/razorpay/webhook' do
    post('callback') do
      tags 'Razorpay'
      consumes 'application/json'

      parameter name: :data, in: :body, schema: { type: :object }
      parameter name: 'X-Razorpay-Signature', in: :header, type: :string, required: true

      let(:'X-Razorpay-Signature') do
        key = ENV.fetch('RAZORPAY_WEBHOOK_SECRET', 'supersecret')
        message = data.to_json
        digest = OpenSSL::Digest.new('sha256')
        OpenSSL::HMAC.hexdigest(digest, key, message)
      end

      response(200, 'successful') do
        let(:subscription) { create(:subscription, plan_type: :razorpay, status: 'created') }
        let(:data) do
          {
            entity: "event",
            account_id: "acc_F5Motm2sJ5Fomd",
            event: "subscription.authenticated",
            contains: [
              "subscription"
            ],
            payload: {
              subscription: {
                entity: {
                  id: subscription.razorpay_subscription_id,
                  entity: "subscription",
                  plan_id: "plan_F5Zu0nrXVhHV2m",
                  customer_id: "cust_F5ZuzTm0cqYpzp",
                  status: "authenticated",
                  current_start: nil,
                  current_end: nil,
                  ended_at: nil,
                  quantity: 1,
                  notes: [],
                  charge_at: 1_593_109_800,
                  start_at: 1_593_109_800,
                  end_at: 1_598_380_200,
                  auth_attempts: 0,
                  total_count: 3,
                  paid_count: 0,
                  customer_notify: true,
                  created_at: 1_592_811_228,
                  expire_by: nil,
                  short_url: nil,
                  has_scheduled_changes: false,
                  change_scheduled_at: nil,
                  source: "api",
                  offer_id: "offer_JHD834hjbxzhd38d",
                  remaining_count: 3
                }
              }
            },
            created_at: 1_592_811_255
          }
        end


        run_test! do
          subscription.reload
          expect(subscription.status).to eq('active')
        end
      end
    end
  end
end
