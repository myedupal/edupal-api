require 'swagger_helper'

RSpec.describe 'api/v1/user/stripes', type: :request do
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }

  path '/api/v1/user/stripe/payment_methods/' do
    get('list payment methods on Stripe') do
      tags 'User Stripe'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      response(200, 'successful') do
        before do
          stripe_customer = Stripe::Customer.create(
            email: user.email,
            name: user.name,
            metadata: {
              user_id: user.id,
              environment: 'test'
            }
          )
          StripeProfile.create(user_id: user.id, customer_id: stripe_customer.id)
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
        end

        run_test!
      end
    end
  end

  path '/api/v1/user/stripe/detach_payment_method/' do
    post('detach payment methods on Stripe') do
      tags 'User Stripe'
      security [{ bearerAuth: nil }]
      consumes 'application/json'

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          stripe: {
            type: :object,
            properties: {
              payment_method_id: { type: :string }
            }
          }
        }
      }

      let!(:stripe_customer) do
        Stripe::Customer.create(
          email: user.email,
          name: user.name,
          metadata: {
            user_id: user.id,
            environment: 'test'
          }
        )
      end

      let!(:payment_method) do
        payment_method = Stripe::PaymentMethod.create(
          {
            type: 'card',
            card: {
              number: '4242424242424242',
              exp_month: 12,
              exp_year: 5.years.from_now.year,
              cvc: '314'
            }
          }
        )
        Stripe::PaymentMethod.attach(payment_method.id, customer: stripe_customer.id)
      end

      let!(:stripe_profile) { StripeProfile.create(user_id: user.id, customer_id: stripe_customer.id, payment_method_id: payment_method.id) }

      response(204, 'no content') do
        let(:data) { { stripe: { payment_method_id: payment_method.id } } }

        run_test! do |_response|
          expect(stripe_profile.reload.payment_method_id).to be_falsey
        end
      end

      response(400, 'bad request') do
        before do
          allow(Stripe::Subscription).to receive_message_chain(:list, :data) { [double(id: subscription_id, default_payment_method: payment_method.id)] }
        end
        let(:data) { { stripe: { payment_method_id: payment_method.id } } }
        let(:subscription_id) { Faker::Internet.uuid }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['metadata']['subscription_ids']).to include(subscription_id)
          expect(stripe_profile.reload.payment_method_id).to be_truthy
        end
      end
    end
  end

  path '/api/v1/user/stripe/setup_intent/' do
    post('create setup_intent') do
      tags 'User Stripe'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful', save_request_example: :data) do
        before do
          stripe_customer = Stripe::Customer.create(
            email: user.email,
            name: user.name,
            metadata: {
              user_id: user.id,
              environment: 'test'
            }
          )
          StripeProfile.create(user_id: user.id, customer_id: stripe_customer.id)
        end

        run_test!
      end
    end
  end

  path '/api/v1/user/stripe/default_payment_method/' do
    put('update/attach a default payment method to stripe_profile') do
      tags 'User Stripe'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          stripe: {
            type: :object,
            properties: {
              payment_method_id: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:payment_method) do
          Stripe::PaymentMethod.create({
                                         type: 'card',
                                         card: {
                                           number: '4242424242424242',
                                           exp_month: 12,
                                           exp_year: 2034,
                                           cvc: '314'
                                         }
                                       })
        end
        let(:data) { { stripe: { payment_method_id: payment_method.id } } }

        before do
          stripe_customer = Stripe::Customer.create(
            email: user.email,
            name: user.name,
            metadata: {
              user_id: user.id,
              environment: 'test'
            }
          )
          StripeProfile.create(user_id: user.id, customer_id: stripe_customer.id)
        end

        run_test! do |response|
          response_body = JSON.parse(response.body)
          stripe_profile = StripeProfile.find_by(user_id: user.id)
          expect(stripe_profile.payment_method_id).to eq(response_body['stripe_profile']['payment_method_id'])
          stripe_customer = Stripe::Customer.retrieve(stripe_profile.customer_id)
          expect(stripe_customer.invoice_settings.default_payment_method).to eq(response_body['stripe_profile']['payment_method_id'])
        end
      end
    end
  end

  path '/api/v1/user/stripe/customer/' do
    get('get Stripe Customer') do
      tags 'User Stripe'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      response(200, 'successful') do
        run_test!
      end
    end
  end
end
