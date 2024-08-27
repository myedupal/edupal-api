require 'swagger_helper'

RSpec.describe 'api/v1/user/quotes', type: :request do
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:quote) { create(:quote, user_id: user.id) }
  let(:id) { quote.id }

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
    payment_method = Stripe::PaymentMethod.attach(payment_method.id, customer: stripe_customer.id)
    StripeProfile.create!(user: user,
                          customer_id: stripe_customer.id,
                          payment_method_id: payment_method.id)
  end

  let(:plan) { create(:plan) }
  let(:price) { create(:price, plan_id: plan.id) }

  path '/api/v1/user/quotes' do
    get('list quotes') do
      tags 'User Quotes'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :status, in: :query, type: :string, required: false, description: 'Filter by status'

      response(200, 'successful') do
        before do
          create_list(:quote, 3, user: user)
        end

        run_test!
      end
    end

    post('create quotes') do
      tags 'User Quotes'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          price_ids: { type: :array, items: { type: :string } },
          promotion_code: { type: :string }
        }
      }

      let(:data) { { price_ids: [price.id] } }

      response(200, 'successful', save_request_example: :data) do
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['quote']['stripe_quote_id']).to be_present
          expect(data['quote']['status']).to eq('open')
        end
      end

      response(422, 'unprocessable entity') do
        before do
          user.stripe_profile.update_column(:payment_method_id, 'pm_1234567890')
        end

        run_test!
      end

      context 'with promotional code' do
        let!(:coupon) { Stripe::Coupon.create(percent_off: 25, duration: 'once', name: 'testing') }
        let!(:promotion_code) { Stripe::PromotionCode.create(coupon: coupon.id) }
        let(:data) { { price_ids: [price.id], promotion_code: promotion_code.code } }

        context 'with valid promotional code' do

          before do
            allow(Stripe::PromotionCode)
              .to receive(:list).with(active: true, code: promotion_code.code, limit: 1).and_call_original
          end

          it 'adds promotion' do
            post '/api/v1/user/quotes', headers: { Authorization: bearer_token_for(user) }, params: data

            expect(response).to have_http_status(:ok)
            expect(Stripe::PromotionCode)
              .to have_received(:list).with(active: true, code: promotion_code.code, limit: 1)
          end
        end

        context 'with invalid promotional code' do
          let(:data) { { price_ids: [price.id], promotion_code: 'promo_12345' } }
          before do
            allow(Stripe::PromotionCode)
              .to receive(:list).with(any_args) { double(data: []) }
          end

          it 'adds promotion' do
            post '/api/v1/user/quotes', headers: { Authorization: bearer_token_for(user) }, params: data

            expect(response).to have_http_status(:unprocessable_entity)
            data = JSON.parse(response.body)
            expect(data['error_messages'].first).to eq(I18n.t('errors.promotion_code_not_found'))
            expect(Stripe::PromotionCode)
              .to have_received(:list)
          end
        end
      end

    end
  end

  path '/api/v1/user/quotes/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show quotes') do
      tags 'User Quotes'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end
  end

  path '/api/v1/user/quotes/{id}/accept' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('accept quotes') do
      tags 'User Quotes'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      let(:quote) do
        organizer = Quote::CreateQuoteOrganizer.call(
          current_user: user,
          price_params: { price_ids: [price.id] }
        )
        organizer.quote
      end

      before do
        allow(Stripe::Invoice).to receive(:finalize_invoice).with(any_args, auto_advance: false) { nil }
        allow(Stripe::Quote)
          .to receive(:accept).and_call_original
      end

      response(200, 'successful', save_request_example: :data) do
        run_test! do |response|
          response_body = JSON.parse(response.body)
          expect(response_body['quote']['status']).to eq('accepted')

          expect(Stripe::Quote).to have_received(:accept).with(quote.stripe_quote_id)
          expect(Stripe::Invoice).to have_received(:finalize_invoice).with(any_args, auto_advance: false)
        end
      end
    end
  end

  path '/api/v1/user/quotes/{id}/payment_intent' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show quotes payment intent') do
      tags 'User Quotes'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(402, 'payment required', save_request_example: :data) do
        before do
          quote.update(status: :accepted)

          allow(Stripe::Quote)
            .to receive_message_chain(:retrieve, :invoice) { double(status: :open, hosted_invoice_url: Faker::Internet.url, payment_intent: Faker::Internet.uuid) }

          allow(Stripe::PaymentIntent)
            .to receive_message_chain(:retrieve) { double(id: Faker::Internet.uuid, client_secret: Faker::Internet.uuid) }
        end

        run_test! do |response|
          response_body = JSON.parse(response.body)
          expect(response_body['payment_intent']).to be_present
          expect(response_body['client_secret']).to be_present
        end
      end

      response(204, 'no content', save_request_example: :data) do
        before do
          quote.update(status: :accepted)
          allow(Stripe::Quote)
            .to receive_message_chain(:retrieve, :invoice, :status) { 'paid' }
        end

        run_test!
      end

      response(422, 'unprocessable entity', save_request_example: :data) do
        before { quote.update(status: :open) }
        run_test!
      end
    end
  end

  path '/api/v1/user/quotes/{id}/cancel' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('cancel quote') do
      tags 'User Quotes'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      response(200, 'successful', save_request_example: :data) do
        let(:stripe_quote_id) { Stripe::Quote.create.id }

        before do
          quote.update(status: :open, stripe_quote_id: stripe_quote_id)
          allow(Stripe::Quote)
            .to receive(:cancel).and_call_original
        end

        run_test! do |response|
          response_body = JSON.parse(response.body)
          expect(response_body['quote']['status']).to eq('canceled')
          expect(Stripe::Quote).to have_received(:cancel).with(stripe_quote_id)
        end
      end
    end
  end

  path '/api/v1/user/quotes/{id}/show_pdf' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show quotes pdf') do
      tags 'User Quotes'
      produces 'application/pdf'
      security [{ bearerAuth: nil }]

      let(:quote) do
        organizer = Quote::CreateQuoteOrganizer.call(
          current_user: user,
          price_params: { price_ids: [price.id] }
        )
        organizer.quote
      end

      response(200, 'successful', save_request_example: :data) do
        before do
          WebMock.stub_request(:get, %r{files.stripe.com/v1/quotes/.*})
            .to_return(status: 200, body: Rails.root.join('spec/fixtures/files/example_quote.pdf').read, headers: {})
        end

        # after do |example|
        #   example.metadata[:response][:content] = { 'application/pdf': { examples: { test_example: { value: response.body } } } }
        # end

        run_test! do |response|
          expect(response.headers['Content-Type']).to eq('application/pdf')
          expect(response.headers['Content-Disposition']).to match(/attachment; filename=.*/)
        end
      end
    end
  end
end
