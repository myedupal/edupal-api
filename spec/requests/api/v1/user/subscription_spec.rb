require 'swagger_helper'

RSpec.describe 'api/v1/user/subscriptions', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:subscription) { create(:subscription, user: user, created_at: 2.months.ago) }
  let(:id) { subscription.id }

  before do
    stripe_customer = Stripe::Customer.create(email: user.email)
    payment_method = Stripe::PaymentMethod.create({
                                                    type: 'card',
                                                    card: {
                                                      number: '4242424242424242',
                                                      exp_month: 12,
                                                      exp_year: 5.years.from_now.year,
                                                      cvc: '314'
                                                    }
                                                  })
    Stripe::PaymentMethod.attach(payment_method.id, customer: stripe_customer.id)
    StripeProfile.create!(user: user,
                          customer_id: stripe_customer.id,
                          payment_method_id: payment_method.id)
  end

  path '/api/v1/user/subscriptions' do
    get('list subscriptions') do
      tags 'User Subscriptions'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :status, in: :query, type: :string, required: false, description: 'Filter by status'

      response(200, 'successful') do
        before do
          create_list(:subscription, 3, user: user)
        end

        run_test!
      end
    end

    post('create subscriptions') do
      tags 'User Subscriptions'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          subscription: {
            type: :object,
            properties: {
              price_id: { type: :string }
            }
          }
        }
      }

      let(:price) { create(:price) }
      let(:data) { { subscription: { price_id: price.id } } }

      context 'when plan type is stripe' do
        response(200, 'successful', save_request_example: :data) do
          run_test! do
            expect(user.reload.active_subscriptions).to be_present
          end
        end

        response(422, 'unprocessable entity') do
          before do
            user.stripe_profile.update_column(:payment_method_id, 'pm_1234567890')
          end

          run_test!
        end
      end

      context 'when plan type is razorpay' do
        let(:plan) { create(:plan, plan_type: :razorpay) }
        let(:id) { create(:subscription, user: user, plan_type: :razorpay, plan: plan).id }
        let(:price) { create(:price, plan: plan) }

        response(200, 'successful', save_request_example: :data) do
          before do
            create(:subscription, user: user, plan_type: :razorpay, status: :active)
          end

          run_test! do |response|
            response_body = JSON.parse(response.body)
            expect(response_body['subscription']['razorpay_short_url']).to be_present
          end
        end

        response(422, 'unprocessable entity') do
          before do
            create(:subscription, user: user, plan_type: :razorpay, status: :active, plan: plan, price: price)
          end

          run_test!
        end
      end

      context 'with referring user' do
        let(:referred_by) { create(:user) }
        let(:user) { create(:user, referred_by: referred_by) }
        it 'create referral activity' do
          post '/api/v1/user/subscriptions', headers: { Authorization: bearer_token_for(user) }, params: { subscription: { price_id: price.id } }

          expect(response).to have_http_status(:ok)
          data = JSON.parse(response.body)
          expect(referred_by.reload.referral_activities.count).to eq(1)
          referral_activity = referred_by.referral_activities.first!
          expect(referral_activity.user).to eq(referred_by)
          expect(referral_activity.referral_source_id).to eq(data['subscription']['id'])
        end
      end
    end
  end

  path '/api/v1/user/subscriptions/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show subscriptions') do
      tags 'User Subscriptions'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update subscriptions') do
      tags 'User Subscriptions'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          subscription: {
            type: :object,
            properties: {
              price_id: { type: :string }
            }
          }
        }
      }

      let(:new_price) { create(:price, :yearly) }
      let(:data) { { subscription: { price_id: new_price.id } } }

      before do
        stripe_subscription = Stripe::Subscription.create(
          customer: user.stripe_profile.customer_id,
          default_payment_method: user.stripe_profile.payment_method_id,
          collection_method: 'charge_automatically',
          payment_behavior: 'error_if_incomplete',
          items: [
            {
              price: subscription.price.stripe_price_id
            }
          ]
        )
        subscription.update_column(:stripe_subscription_id, stripe_subscription.id)
      end

      context 'when plan type is stripe' do
        response(200, 'successful', save_request_example: :data) do
          run_test!
        end

        response(422, 'unprocessable entity') do
          before do
            user.stripe_profile.update_column(:payment_method_id, 'pm_1234567890')
          end

          run_test!
        end
      end

      context 'when plan type is razorpay' do
        let(:plan) { create(:plan, plan_type: :razorpay) }
        let(:id) { create(:subscription, user: user, plan_type: :razorpay, plan: plan).id }
        let(:new_price) { create(:price, :yearly, plan: plan) }

        response(200, 'successful', save_request_example: :data) do
          run_test! do |response|
            response_body = JSON.parse(response.body)
            expect(response_body['subscription']['razorpay_short_url']).to be_present
          end
        end

        response(422, 'unprocessable entity') do
          let(:data) { { subscription: { price_id: SecureRandom.uuid } } }
          run_test!
        end
      end
    end
  end

  path '/api/v1/user/subscriptions/{id}/cancel' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('cancel subscriptions') do
      tags 'User Subscriptions'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          subscription: {
            type: :object,
            properties: {
              cancel_at_period_end: { type: :boolean },
              cancel_reason: { type: :string }
            }
          }
        }
      }

      let(:data) { { subscription: { cancel_reason: Faker::Lorem.sentence } } }

      before do
        stripe_subscription = Stripe::Subscription.create(
          customer: user.stripe_profile.customer_id,
          default_payment_method: user.stripe_profile.payment_method_id,
          collection_method: 'charge_automatically',
          payment_behavior: 'error_if_incomplete',
          items: [
            {
              price: subscription.price.stripe_price_id
            }
          ]
        )
        subscription.update_column(:stripe_subscription_id, stripe_subscription.id)
      end

      context 'when plan type is stripe' do
        response(200, 'successful', save_request_example: :data) do
          run_test! do |response|
            response_body = JSON.parse(response.body)
            expect(response_body['subscription']['status']).to eq('canceled')
          end
        end

        context 'when cancel_at_period_end is true' do
          let(:data) { { subscription: { cancel_at_period_end: true } } }

          it 'remains active' do
            put "/api/v1/user/subscriptions/#{id}/cancel", headers: { Authorization: bearer_token_for(user) }, params: data
            expect(response).to have_http_status(:ok)
            response_body = JSON.parse(response.body)
            expect(response_body['subscription']['status']).to eq('active')
            expect(response_body['subscription']['cancel_at_period_end']).to eq(true)
          end
        end
      end

      context 'when plan type is razorpay' do
        let(:id) { create(:subscription, user: user, plan_type: :razorpay).id }

        response(200, 'successful', save_request_example: :data) do
          run_test! do |response|
            response_body = JSON.parse(response.body)
            expect(response_body['subscription']['status']).to eq('cancelled')
          end
        end

        context 'when cancel_at_period_end is true' do
          let(:data) { { subscription: { cancel_at_period_end: true } } }

          it 'remains active' do
            put "/api/v1/user/subscriptions/#{id}/cancel", headers: { Authorization: bearer_token_for(user) }, params: data
            expect(response).to have_http_status(:ok)
            response_body = JSON.parse(response.body)
            expect(response_body['subscription']['status']).to eq('active')
            expect(response_body['subscription']['cancel_at_period_end']).to be_truthy
          end
        end
      end
    end
  end

  path '/api/v1/user/subscriptions/redeem' do
    post('redeem subscriptions') do
      tags 'User Subscriptions'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          subscription: {
            type: :object,
            properties: {
              redeem_code: { type: :string }
            }
          }
        }
      }

      let(:gift_card) { create(:gift_card) }
      let(:data) { { subscription: { redeem_code: gift_card.code } } }

      response(200, 'successful', save_request_example: :data) do
        before do
          create(:subscription, user: user, status: :active)
        end

        run_test! do |response|
          response_body = JSON.parse(response.body)
          expect(response_body['subscription']['status']).to eq('active')
          expect(user.reload.active_subscriptions).to be_present
        end
      end

      response(400, 'bad_request', save_request_example: :data) do
        let(:gift_card) { create(:gift_card, expires_at: 1.day.ago) }

        run_test!
      end

      context 'when user already has an active subscription for plan' do
        before do
          create(:subscription, user: user, status: :active, plan: gift_card.plan)
        end

        response(400, 'bad_request', save_request_example: :data) do
          run_test!
        end
      end
    end
  end
end
