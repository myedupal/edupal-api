require 'swagger_helper'

RSpec.describe 'api/v1/admin/account', type: :request do
  let(:user) { create(:admin) }
  let(:Authorization) { bearer_token_for(user) }

  path '/api/v1/admin/account' do
    get('show account') do
      response(200, 'successful') do
        tags 'Admin Account'
        produces 'application/json'
        security [{ bearerAuth: nil }]

        run_test!
      end
    end

    put('update account') do
      tags 'Admin Account'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          account: {
            type: :object,
            properties: {
              name: { type: :string },
              email: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { account: attributes_for(:admin).slice(:email, :name) } }

        run_test!
      end
    end
  end

  path '/api/v1/admin/account/password' do
    put('update account password') do
      tags 'Admin Account'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          account: {
            type: :object,
            properties: {
              current_password: { type: :string },
              password: { type: :string },
              password_confirmation: { type: :string }
            }
          }
        }
      }

      let(:current_password) { SecureRandom.uuid }
      let(:password) { SecureRandom.uuid }

      before do
        user.update(password: current_password)
      end

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { account: { current_password: current_password, password: password, password_confirmation: password } } }

        run_test!
      end

      response(422, 'successful', save_request_example: :data) do
        let(:data) { { account: { current_password: 'password', password: password, password_confirmation: password } } }

        run_test!
      end
    end
  end
end
