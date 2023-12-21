require 'swagger_helper'

RSpec.describe 'api/v1/user/sessions', type: :request do
  let(:user) { create(:user, password: 'password') }

  path '/api/v1/user/sign_in' do
    post('Sign in') do
      tags 'User Sessions'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'user@test.com' },
              password: { type: :string, example: 'password' }
            },
            required: %w[email password]
          }
        }
      }
      response(200, 'successful', save_request_example: :data) do
        header 'Authorization', schema: { type: :string }, description: 'Bearer token'
        let(:data) do
          {
            user: {
              email: user.email,
              password: 'password'
            }
          }
        end

        run_test!
      end

      response(401, 'unauthorized') do
        let(:data) do
          {
            user: {
              email: user.email,
              password: 'wrong_password'
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/user/sign_out' do
    delete('Sign out') do
      tags 'User Sessions'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        let(:Authorization) { bearer_token_for(create(:user)) }

        run_test!
      end
    end
  end
end
